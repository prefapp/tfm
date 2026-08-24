# Context Map

This `modules/*` monorepo has multiple contexts — one per module. Each context's
glossary lives in its `modules/<module>/CONTEXT.md`, next to the code it describes.
Terms are authored lazily as modules are touched; most links below are still
wired-but-empty stubs.

Layout:

```
/
├── CONTEXT.md                  ← shared kernel: vocabulary every context inherits
├── CONTEXT-MAP.md              ← this file
├── docs/adr/                   ← repo-wide ADRs
└── modules/<module>/
    ├── CONTEXT.md              ← this module's glossary
    └── docs/adr/               ← module-scoped ADRs (created lazily)
```

## Shared kernel

[`CONTEXT.md`](./CONTEXT.md) holds the cross-cutting vocabulary — Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module. Every context below
inherits it and must not redefine those terms.

## Contexts

Grouped by provider plane for readability. The grouping is presentational; each module
is its own context.

### AWS

- [aws-amq-rabbit](./modules/aws-amq-rabbit/CONTEXT.md) — Amazon MQ RabbitMQ broker
- [aws-backup](./modules/aws-backup/CONTEXT.md) — AWS Backup vaults, plans and selections
- [aws-cloudfront-delivery](./modules/aws-cloudfront-delivery/CONTEXT.md) — CloudFront distribution with S3 origin
- [aws-ecr](./modules/aws-ecr/CONTEXT.md) — **not a module** — documentation pointing at the upstream community ECR module
- [aws-ecs](./modules/aws-ecs/CONTEXT.md) — ECS Fargate cluster, services and load balancing
- [aws-eks](./modules/aws-eks/CONTEXT.md) — EKS cluster and node groups
- [aws-kms](./modules/aws-kms/CONTEXT.md) — A single KMS key and alias
- [aws-kms-multiple](./modules/aws-kms-multiple/CONTEXT.md) — Several KMS keys from one config
- [aws-oidc](./modules/aws-oidc/CONTEXT.md) — OIDC provider and federated IAM roles
- [aws-parameter-store](./modules/aws-parameter-store/CONTEXT.md) — SSM Parameter Store parameters
- [aws-parameter-store-replication](./modules/aws-parameter-store-replication/CONTEXT.md) — Cross-account/region SSM parameter replication
- [aws-rds](./modules/aws-rds/CONTEXT.md) — RDS instances and clusters
- [aws-s3](./modules/aws-s3/CONTEXT.md) — S3 buckets and bucket-level policies
- [aws-secretsmanager-replication](./modules/aws-secretsmanager-replication/CONTEXT.md) — Cross-region Secrets Manager replication
- [aws-sso](./modules/aws-sso/CONTEXT.md) — IAM Identity Center permission sets and assignments
- [aws-terraform-backend](./modules/aws-terraform-backend/CONTEXT.md) — S3 bucket + DynamoDB table backing Terraform state
- [aws-vpc](./modules/aws-vpc/CONTEXT.md) — **not a module** — documentation pointing at the upstream community VPC module
- [aws-waf](./modules/aws-waf/CONTEXT.md) — WAFv2 web ACLs and rules

### Azure

- [azure-aks](./modules/azure-aks/CONTEXT.md) — AKS cluster and node pools
- [azure-alerts](./modules/azure-alerts/CONTEXT.md) — Monitor alert rules and action groups
- [azure-app-gateway](./modules/azure-app-gateway/CONTEXT.md) — Application Gateway
- [azure-application](./modules/azure-application/CONTEXT.md) — Entra ID application registration and service principal
- [azure-backup-vault](./modules/azure-backup-vault/CONTEXT.md) — Backup vault and policies
- [azure-customrole](./modules/azure-customrole/CONTEXT.md) — Custom RBAC role definitions
- [azure-disks](./modules/azure-disks/CONTEXT.md) — Managed disks
- [azure-disks-backup](./modules/azure-disks-backup/CONTEXT.md) — Backup instances for managed disks
- [azure-dns-zone](./modules/azure-dns-zone/CONTEXT.md) — Public DNS zones and records
- [azure-event-hub](./modules/azure-event-hub/CONTEXT.md) — Event Hubs namespace and hubs
- [azure-flexible-server-postgresql](./modules/azure-flexible-server-postgresql/CONTEXT.md) — PostgreSQL Flexible Server
- [azure-kv](./modules/azure-kv/CONTEXT.md) — Key Vault, access policies and secrets
- [azure-linux-vm](./modules/azure-linux-vm/CONTEXT.md) — Linux virtual machines
- [azure-localnet-gateway](./modules/azure-localnet-gateway/CONTEXT.md) — Local network gateway
- [azure-managed-redis](./modules/azure-managed-redis/CONTEXT.md) — Azure Managed Redis
- [azure-mi](./modules/azure-mi/CONTEXT.md) — User-assigned managed identities
- [azure-nat-gateway](./modules/azure-nat-gateway/CONTEXT.md) — NAT gateway and associations
- [azure-nsg-nsr](./modules/azure-nsg-nsr/CONTEXT.md) — Network security groups and rules
- [azure-oidc](./modules/azure-oidc/CONTEXT.md) — Workload identity federation credentials
- [azure-policy-assignments](./modules/azure-policy-assignments/CONTEXT.md) — Policy assignments
- [azure-policy-definitions](./modules/azure-policy-definitions/CONTEXT.md) — Policy definitions
- [azure-private-dns-zone](./modules/azure-private-dns-zone/CONTEXT.md) — Private DNS zones and vnet links
- [azure-public-ip](./modules/azure-public-ip/CONTEXT.md) — Public IP addresses
- [azure-public-prefix](./modules/azure-public-prefix/CONTEXT.md) — Public IP prefixes
- [azure-redis-cache](./modules/azure-redis-cache/CONTEXT.md) — Azure Cache for Redis
- [azure-resource-group](./modules/azure-resource-group/CONTEXT.md) — Resource groups
- [azure-role-assignment](./modules/azure-role-assignment/CONTEXT.md) — RBAC role assignments
- [azure-sa](./modules/azure-sa/CONTEXT.md) — Storage accounts and containers
- [azure-sa-backup](./modules/azure-sa-backup/CONTEXT.md) — Backup instances for storage accounts
- [azure-vmss](./modules/azure-vmss/CONTEXT.md) — Virtual machine scale sets
- [azure-vnet-and-subnet](./modules/azure-vnet-and-subnet/CONTEXT.md) — Virtual networks and subnets
- [azure-vnet-gateway](./modules/azure-vnet-gateway/CONTEXT.md) — Virtual network gateway
- [azure-vnet-gateway-connection](./modules/azure-vnet-gateway-connection/CONTEXT.md) — Gateway connections
- [azure-vnet-peering](./modules/azure-vnet-peering/CONTEXT.md) — Vnet peerings
- [azure-windows-vm](./modules/azure-windows-vm/CONTEXT.md) — Windows virtual machines
- [azuread-group](./modules/azuread-group/CONTEXT.md) — Entra ID security group, RBAC/directory roles and PIM

### GitHub

- [github-files-set](./modules/github-files-set/CONTEXT.md) — A set of managed files in a repository (composite module)
- [github-membership](./modules/github-membership/CONTEXT.md) — Organisation membership
- [github-org-ruleset](./modules/github-org-ruleset/CONTEXT.md) — A single organisation ruleset
- [github-org-rulesets](./modules/github-org-rulesets/CONTEXT.md) — Several organisation rulesets (composite module)
- [github-org-settings](./modules/github-org-settings/CONTEXT.md) — Organisation-level settings
- [github-org-variables-section](./modules/github-org-variables-section/CONTEXT.md) — A section of organisation Actions variables
- [github-org-webhook](./modules/github-org-webhook/CONTEXT.md) — Organisation webhooks
- [github-repo](./modules/github-repo/CONTEXT.md) — A repository, its default branch and labels
- [github-repo-secrets-section](./modules/github-repo-secrets-section/CONTEXT.md) — A section of repository Actions/Dependabot/Codespaces secrets
- [github-team](./modules/github-team/CONTEXT.md) — Teams, members and repository grants

### MongoDB Atlas

- [mongodb-atlas-project](./modules/mongodb-atlas-project/CONTEXT.md) — Atlas project and project-level settings
- [mongodb-atlas-cluster](./modules/mongodb-atlas-cluster/CONTEXT.md) — Atlas cluster
- [mongodb-atlas-azure-privatelink](./modules/mongodb-atlas-azure-privatelink/CONTEXT.md) — Private Link between an Atlas project and an Azure vnet

### CloudAMQP

- [cloudamqp-cluster](./modules/cloudamqp-cluster/CONTEXT.md) — CloudAMQP instance
- [cloudamqp-vpc](./modules/cloudamqp-vpc/CONTEXT.md) — CloudAMQP VPC and optional VPC connect

### Testing

- [dummy](./modules/dummy/CONTEXT.md) — Simulated latency and failures at plan/apply/destroy, for pipeline testing

## Relationships

- **every context → shared kernel**: all modules inherit the root `CONTEXT.md`
  vocabulary. A term that means the same thing everywhere belongs there, not in a
  module glossary.
- **the ghaps group**: all ten `github-*` modules — and only those — implement the
  ghaps `config` contract (one `variable "config"`, one CR, one Terraform state, one
  generated `terraform.tfvars.json`). [`RULES.md`](./RULES.md) applies to them and to
  no other module.
- **`azuread-group`, `azure-application`, `azure-oidc` → the Azure modules**: these
  own Microsoft Entra ID directory objects rather than subscription resources. They
  pull the `azurerm` provider only to attach subscription-scoped role assignments.
  `azure-kv` is the reverse case: a subscription resource that reads directory
  principals for its access policies.
- **`mongodb-atlas-azure-privatelink` → the Azure modules**: the only module spanning
  two provider planes, requiring both `mongodbatlas` and `azurerm`. The Azure vnet it
  attaches to is referenced by ID, never managed here.
- **`aws-terraform-backend` → every context**: it provisions the S3 bucket and
  DynamoDB table that materialise the *state boundary* term for consumers.
- **`dummy` → nothing**: it deliberately touches no provider. It exists to exercise
  provisioning and CI, so it may model failure modes the real modules must never have.

## Maintaining this map

Contexts and terms are authored **lazily**, as modules are touched. When you add a
module, create its `CONTEXT.md` stub and add its line here in the same pull request.
When a term turns out to mean the same thing in every module, promote it to the shared
kernel instead of repeating it.
