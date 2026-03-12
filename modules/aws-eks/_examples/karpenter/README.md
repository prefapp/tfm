# 🚀 Karpenter - Node Autoscaling on EKS

The directory karpenter_config contains the full configuration to install and use Karpenter in your EKS cluster.

---

## 📚 What is Karpenter?

**Karpenter** is a node autoscaler for Kubernetes that:
- ✅ **Creates nodes automatically** when there are pending pods
- ✅ **Removes nodes** when they are empty or underutilized (consolidation)
- ✅ **Optimizes costs** by choosing the right instance type
- ✅ **Reacts fast** (seconds, not minutes like Cluster Autoscaler)

---

### Key Components

| Component | Description | File |
|-----------|-------------|------|
| **Karpenter Controller** | Pod that manages autoscaling | Installed via Helm |
| **EC2NodeClass** | AWS infra (AMI, subnets, security groups) | `ec2nodeclass-on-demand-default.yaml` |
| **NodePool (base)** | Generic on-demand pool (no taints) | `nodepool-on-demand-default.yaml` |
| **NodePool (dev)** | Pool for dev nodes (taint/label dev, on-demand) | `nodepool-on-demand-dev.yaml` |
| **NodePool (dev spot)** | Pool for dev nodes on spot (lower weight) | `nodepool-spot-dev.yaml` |
| **Pod** | Your app that needs capacity | `deployment-dev.yaml` |

---

## 📦 Installation

### Option A (scripts)
Run everything in one shot:
```bash
cd /tfm/modules/aws-eks/_examples/karpenter/karpenter_config
chmod +x *.sh
./aplicar-configuracion.sh
```
- What the script does:
  1) Verifies the SQS queue exists (created by Terraform)
  2) Installs Karpenter with Helm using `values.yaml`
  3) Configures the ServiceAccount with the correct IAM role
  4) Sets the cluster name and SQS queue

### Option B (manual, no scripts)
Apply each component separately (useful if you want to review/edit manifests first).

1) Install the Karpenter chart with your `values.yaml`
```bash
helm upgrade --install karpenter \
  oci://public.ecr.aws/karpenter/karpenter \
  --namespace karpenter --create-namespace \
  -f values.yaml
```
- Adjust in `values.yaml`:
  - `serviceAccount.annotations.eks.amazonaws.com/role-arn`: IAM role ARN for Karpenter.
  - `settings.clusterName`: EKS cluster name.
  - `settings.interruptionQueue`: SQS queue name created by Terraform.

2) Apply infra (EC2NodeClass)
```bash
kubectl apply -f ec2nodeclass-on-demand-default.yaml
```
- Edit before applying if needed:
  - `subnetSelectorTerms` / `securityGroupSelectorTerms`: tags (or IDs) for your subnets/SG.
  - `amiSelectorTerms` or a specific `ami`.
  - `role`: IAM role for Karpenter nodes.

3) Apply NodePools
```bash
kubectl apply -f nodepool-on-demand-default.yaml
kubectl apply -f nodepool-on-demand-dev.yaml
```
- Base pool: generic on-demand capacity.
- Dev pool: label `environment: dev` and taint `environment=dev:NoSchedule` to isolate dev nodes.
- Optional spot pool for dev:
```bash
kubectl apply -f nodepool-spot-dev.yaml
```
- Spot pool uses `capacity-type: spot`, lower weight (5) so Karpenter will prefer it when available/cost-effective.

4) (Optional) Example deployment
```bash
kubectl apply -f deployment-dev.yaml
```
- Includes `nodeSelector: environment: dev` and the matching toleration.

5) Quick checks
```bash
kubectl get nodepool -n kube-system
kubectl get ec2nodeclass
kubectl get pods -n default -o wide
kubectl get nodes --show-labels
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=50
```

6) Manual uninstall (no scripts)
```bash
kubectl delete -f deployment-dev.yaml      # if applied
kubectl delete -f nodepool-on-demand-dev.yaml
kubectl delete -f nodepool-spot-dev.yaml   # if applied
kubectl delete -f nodepool-on-demand-default.yaml
kubectl delete -f ec2nodeclass-on-demand-default.yaml
helm uninstall karpenter -n karpenter
```

---

## 🚧 Multiple environments (dev / pre) and NodeClasses

To split nodes per environment:
- Create one NodePool per env (e.g., `karpenter-dev`, `karpenter-pre`), each with:
  - `labels`: `environment: dev` / `environment: pre`
  - `taints`: `environment=dev:NoSchedule` / `environment=pre:NoSchedule`
  - Pods must set matching `nodeSelector` + `tolerations`.
- Infrastructure (EC2NodeClass):
  - You can **reuse the same** `EC2NodeClass` if subnets/SG/AMI/role are shared.
  - Or create **one per env** (change `name` and point `nodeClassRef` to it).

Quick example for a “pre” NodePool (reusing the existing EC2NodeClass):
```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: karpenter-pre
spec:
  template:
    metadata:
      labels:
        environment: pre
    spec:
      taints:
        - key: environment
          value: pre
          effect: NoSchedule
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["m6a.large","m6a.xlarge"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["m"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["5"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: karpenter-on-demand-default  # or your env-specific NodeClass
  limits:
    cpu: 20
    memory: "80Gi"
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 1m
  weight: 10
```

Reminder: “pre” pods must set `nodeSelector: {environment: pre}` and toleration `environment=pre:NoSchedule`.

---

## 🔄 How Autoscaling Works

### Scenario: Deploy a Pod that needs a node

1) Example pod
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  template:
    spec:
      nodeSelector:
        environment: dev  # requires a node with this label
      tolerations:
        - key: environment
          value: dev
          effect: NoSchedule  # allows running on nodes with this taint
      containers:
      - name: app
        resources:
          requests:
            cpu: "1000m"
            memory: "1Gi"
```

2) Karpenter sees the pending pod
- Continuously watches Pending pods and their requirements: CPU, memory, nodeSelector, tolerations.

3) Karpenter picks a NodePool
- Evaluates NodePools by:
  1. **Weight** (priority)
  2. **Requirements** (can it create nodes that satisfy the pod?)
  3. **Cost** (chooses the cheapest valid option)
- Here:
  - Pod: `environment: dev` + toleration `environment=dev:NoSchedule`
  - NodePool `karpenter-dev`: label `environment: dev`, taint `environment=dev:NoSchedule`, instance types `m6a.large|m6a.xlarge`
  - Result: Karpenter selects `karpenter-dev`.

4) Karpenter creates the EC2 instance
- Uses the referenced **EC2NodeClass**:
  - AMI: Amazon Linux 2023 (`amiSelectorTerms`)
  - Subnets: private subnets (`subnetSelectorTerms`)
  - Security Groups: `kubernetes-my-org-dev-node` (`securityGroupSelectorTerms`)
  - IAM Role: `Karpenter-kubernetes-my-org-dev`
  - Storage: 100Gi gp3 encrypted
- Chooses the smallest fitting instance (e.g., `m6a.large` for 1 CPU / 1Gi).

5) Instance joins the cluster
- Bootstraps EKS, joins, gets labels/taints from the NodePool:
  - Label: `environment: dev`
  - Taint: `environment=dev:NoSchedule`

6) Kubernetes schedules the pod
```bash
kubectl get pods
# NAME      READY   STATUS    NODE
# my-app-1  1/1     Running   ip-10-1-19-235.eu-west-1.compute.internal
```

---

## 🎯 NodePool Configuration Notes

1) Labels & taints
```yaml
metadata:
  name: karpenter-dev
spec:
  template:
    metadata:
      labels:
        environment: dev  # pods with nodeSelector "environment: dev" land here
    spec:
      taints:
        - key: environment
          value: dev
          effect: NoSchedule  # only pods with toleration can run here
```

2) Requirements (instance types, capacity type, etc.)
```yaml
requirements:
  - key: node.kubernetes.io/instance-type
    operator: In
    values: ["m6a.large","m6a.xlarge"]
  - key: karpenter.sh/capacity-type
    operator: In
    values: ["on-demand"]
```

3) NodeClassRef (infra binding)
```yaml
nodeClassRef:
  group: karpenter.k8s.aws
  kind: EC2NodeClass
  name: karpenter-on-demand-default  # reference to the NodeClass
```

4) Weight (priority)
```yaml
weight: 10  # higher = more priority if multiple NodePools match
```

---

## 🗑️ Uninstall

```bash
./desinstalar-karpenter.sh
```

The script:
1. Deletes the example deployments
2. Deletes the NodePools (Karpenter then drains/removes nodes)
3. Uninstalls Karpenter via Helm

---

## 📋 Directory Files

| File | Description |
|------|-------------|
| `values.yaml` | Helm values for Karpenter |
| `instalar-karpenter.sh` | Install script |
| `aplicar-configuracion.sh` | One-shot install (Karpenter + NodePools + Deployment) |
| `desinstalar-karpenter.sh` | Uninstall script |
| `ec2nodeclass-on-demand-default.yaml` | EC2NodeClass (on-demand) |
| `nodepool-on-demand-default.yaml` | Base on-demand NodePool |
| `nodepool-on-demand-dev.yaml` | Dev NodePool (on-demand) |
| `nodepool-spot-dev.yaml` | Dev NodePool (spot, lower weight) |
| `deployment-dev.yaml` | Example deployment targeting dev nodes |

---

## 💡 Key Concepts

### NodePool vs EC2NodeClass
- **NodePool**: defines **what** to create (labels, taints, instance types, limits).
- **EC2NodeClass**: defines **how** to create nodes (AMI, subnets, security groups, IAM, storage).
- You can have:
  - Multiple NodePools sharing one EC2NodeClass (shared infra)
  - A dedicated EC2NodeClass per NodePool (isolated infra)

### Taints and Tolerations
- **Taint**: “only pods with this toleration can run here.”
- **Toleration**: “this pod accepts that taint.”
- Example: NodePool taint `environment=dev:NoSchedule`, pod toleration `environment=dev:NoSchedule`.

### NodeSelector vs NodeAffinity
- **NodeSelector**: simple equals match.
- **NodeAffinity**: more flexible (`In`, `NotIn`, `Exists`, etc.).
```yaml
nodeSelector:
  environment: dev
```
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: environment
          operator: In
          values: ["dev","pre"]
```

---

## 🚀 Quick Use
```bash
# Install everything
./aplicar-configuracion.sh

# Uninstall
./desinstalar-karpenter.sh
```

---

## 📚 More Info
- [Karpenter docs](https://karpenter.sh/)
- [NodePools](https://karpenter.sh/docs/concepts/nodepools/)
- [EC2NodeClass](https://karpenter.sh/docs/concepts/nodeclasses/)
