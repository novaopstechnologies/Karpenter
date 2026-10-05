# karpenter-terraform-project

Terraform + Kubernetes project that stands up an Amazon EKS cluster with
[Karpenter](https://karpenter.sh) for node autoscaling, plus a
Prometheus/Grafana monitoring stack and a sample application.

## What this builds

- **VPC** — public + private subnets across 3 AZs, NAT gateways, IGW, and the
  subnet/security-group tags Karpenter needs for discovery.
- **EKS cluster** — a small managed "system" node group (2–3 `t3.medium`
  nodes) that runs core add-ons, CoreDNS, the Karpenter controller, and the
  monitoring stack. Application workloads are left for Karpenter to
  provision on-demand.
- **IAM** — the Karpenter controller's IRSA role, the node role/instance
  profile EC2 instances launched by Karpenter assume, and the SQS queue +
  EventBridge rules used for spot interruption handling.
- **Karpenter** — installed via Helm, with a `NodePool` and `EC2NodeClass`
  applied afterward (spot-first, falls back to on-demand, consolidates
  idle/underutilized nodes after 1 minute).
- **Monitoring** — `kube-prometheus-stack` (Prometheus + Alertmanager) and a
  separate Grafana release, pre-wired to the same Prometheus datasource.
- **Sample app** — an nginx `Deployment` + `Service` + ALB `Ingress` so you
  have something to watch Karpenter schedule and scale.

## Folder structure

```
karpenter-terraform-project/
├── terraform/
│   ├── main.tf              # wires all modules together
│   ├── providers.tf         # aws / kubernetes / helm providers
│   ├── versions.tf          # required Terraform + provider versions
│   ├── backend.tf           # S3 remote state (edit before use)
│   ├── variables.tf / terraform.tfvars / outputs.tf
│   └── modules/
│       ├── vpc/              # VPC, subnets, NAT, routing
│       ├── iam/               # Karpenter IAM (controller + node role, SQS)
│       ├── eks/                # EKS cluster, OIDC provider, system nodes
│       ├── karpenter/          # Helm release + NodePool/EC2NodeClass apply
│       ├── monitoring/         # Prometheus + Grafana Helm releases
│       └── applications/       # applies kubernetes/ manifests
├── kubernetes/
│   ├── nodepool.yaml
│   ├── ec2nodeclass.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── helm-values/
    ├── karpenter-values.yaml
    ├── prometheus-values.yaml
    └── grafana-values.yaml
```

## Prerequisites

- Terraform >= 1.6
- AWS CLI configured with credentials that can create VPC/EKS/IAM resources
- `kubectl`
- An S3 bucket + DynamoDB table for remote state (or comment out
  `backend.tf` to use local state for a quick test)

## Before you run it

1. Edit `terraform/backend.tf` with your own state bucket/table, or remove
   the `backend "s3"` block.
2. Review `terraform/terraform.tfvars` — region, cluster name, CIDRs,
   instance types.
3. Change the Grafana admin password in `helm-values/grafana-values.yaml`
   (or better, move it to a Kubernetes secret before this goes anywhere
   real).

## Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Apply order (handled automatically via `depends_on`): VPC → EKS cluster →
Karpenter IAM → Karpenter Helm release + NodePool/EC2NodeClass → monitoring
stack → sample app.

Point `kubectl` at the new cluster:

```bash
aws eks update-kubeconfig --region <aws_region> --name <cluster_name>
kubectl get nodes
kubectl get pods -n karpenter
kubectl get nodepool,ec2nodeclass
```

Scale the sample app up and watch Karpenter provision nodes for it:

```bash
kubectl scale deployment demo-app --replicas=20
kubectl get nodeclaims -w
```

## Notes / things to adapt

- **NodePool/EC2NodeClass are applied via `local-exec` + `kubectl`**, not
  native Terraform resources — `kubernetes_manifest` has known problems
  managing CRDs that don't exist until the Helm chart installs them. If
  you'd rather go GitOps, point ArgoCD at the `kubernetes/` folder instead
  and drop the `applications` and part of the `karpenter` module.
- **Ingress requires the AWS Load Balancer Controller**, which isn't
  installed by this project. Add it as another `helm_release` if you need
  the ALB to actually provision.
- This is a demo/reference setup, not a hardened production baseline —
  in particular, review IAM policy scoping, NAT gateway cost (one per AZ
  here), and Grafana secret handling before using it for anything real.

## Cleanup

```bash
terraform destroy
```

Karpenter-provisioned EC2 nodes are cleaned up automatically when the
NodePool is deleted as part of the apply's reverse order; if `destroy`
gets stuck on the VPC because of leftover ENIs, check for nodes Karpenter
launched outside of Terraform's knowledge and remove them manually first.
