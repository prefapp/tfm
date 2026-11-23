<!-- BEGIN_TF_DOCS -->
> [!WARNING]
> **Avoid MKS-reserved private network CIDRs.** Do not use these ranges in the private network attached to your cluster:
>
> - **Free plan:** `10.2.0.0/16`, `10.3.0.0/16`, and `172.17.0.0/16`.
> - **Standard plan:** `10.240.0.0/13` and `10.3.0.0/16`.
>
> Standard plan pod and service ranges can be customized when creating or resetting a cluster. Changing them on a running cluster requires a reset and can cause data loss. See [OVHcloud MKS known limits](https://docs.ovhcloud.com/en/guides/public-cloud/containers-orchestration/managed-kubernetes/known-limits/).

# **OVHcloud Managed Kubernetes Service (MKS) Terraform Module**

## Overview

This module provisions an OVHcloud Managed Kubernetes Service (MKS) cluster and its node pools in an existing active Public Cloud project. It discovers the project from the supplied project selector, verifies that the project includes the requested cluster region, and discovers the private network and subnet within that region; the network and subnet are not created by this module.

Use it for a free control-plane cluster, a single-region cluster with one pool, or a standard multi-zone cluster with separate pools per availability zone. The cluster's Kubernetes version and update policy are configurable, and node pools support desired/minimum/maximum capacity, autoscaling, anti-affinity, and availability-zone placement.

## Key Features

- **Managed cluster**: Provisions an OVHcloud MKS cluster with a selected region, plan, Kubernetes version, and update policy.
- **Existing-network discovery**: Selects the private network by exact name and subnet by CIDR in the cluster region.
- **Private-only node networking**: Standard clusters can disable public exposure and optionally route node traffic through the gateway announced by the nodes subnet.
- **Flexible node pools**: Creates one or more named pools with independent capacity limits and optional zone placement.
- **Autoscaling and placement**: Configures pool autoscaling and anti-affinity consistently across the pools.
- **Sensitive kubeconfig**: Exposes the cluster kubeconfig only as a sensitive Terraform output.

## Basic Usage

Use a released module tag in the Git source. Replace the example project, network, subnet, region, Kubernetes version, and flavor with values available in your OVHcloud account. `project_id` can be used instead of `project_name` and takes precedence when both are set.

### Standard multi-zone cluster

```hcl
module "ovh_mks" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mks?ref=ovh-mks-vx.y.z"

  project_name    = "example-project"
  cluster_name    = "example-mks"
  cluster_plan    = "standard"
  region          = "EU-WEST-PAR"
  cluster_version = "<supported-version>"
  network_name    = "example-private-network"
  subnet_cidr     = "10.40.0.0/16"

  node_flavor   = "<available-flavor>"
  autoscale     = true
  anti_affinity = true
  node_pools = {
    zone-a = {
      desired_nodes      = 1
      min_nodes          = 1
      max_nodes          = 3
      availability_zones = ["eu-west-par-a"]
    }
    zone-b = {
      desired_nodes      = 0
      min_nodes          = 0
      max_nodes          = 3
      availability_zones = ["eu-west-par-b"]
    }
    zone-c = {
      desired_nodes      = 0
      min_nodes          = 0
      max_nodes          = 3
      availability_zones = ["eu-west-par-c"]
    }
  }
}
```

### Free control plane without worker nodes

```hcl
module "ovh_mks_free" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mks?ref=ovh-mks-vx.y.z"

  project_name    = "example-project"
  cluster_name    = "example-mks-free"
  cluster_plan    = "free"
  region          = "GRA11"
  cluster_version = "<supported-version>"
  network_name    = "example-gra-private-network"
  subnet_cidr     = "10.41.0.0/16"

  node_flavor   = "<available-flavor>"
  autoscale     = false
  anti_affinity = false
  node_pools = {
    empty = {
      desired_nodes      = 0
      min_nodes          = 0
      max_nodes          = 0
      availability_zones = []
    }
  }
}
```

The free plan applies to the managed control plane. This example requests no worker nodes; creating or scaling worker nodes, and using other billable Public Cloud resources, may incur charges. See [`_examples/`](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks/_examples) for complete examples, including a single pool without a fixed availability zone.

The private network and subnet must already exist in the selected Public Cloud project and region. They can be created separately with the [`ovh-network` module](https://github.com/prefapp/tfm/tree/main/modules/ovh-network).

For a Standard cluster, set `disable_public_networking = true` to prevent public exposure of nodes and workloads. To use the gateway announced by the nodes subnet, also set `use_user_gateway = true`; the subnet must have a valid gateway configured and managed gateway requirements do not apply. These options require OVH provider version 2.23.0 or later, are not supported on the Free plan, and must be configured when creating the cluster. The Kubernetes API endpoint remains publicly reachable subject to its IP restrictions.

Set `attach_floating_ips = true` to attach Floating IPs to nodes in all node pools; it is disabled by default and the provider block is omitted unless enabled. OVHcloud supports node Floating IPs only for compatible Standard clusters and rejects them when `disable_public_networking = true`; the module validates this incompatible combination before apply. Floating IPs may incur charges and are available only in supported regions.

For a Standard cluster deployed across multiple availability zones, OVHcloud requires a Public Cloud gateway attached to the private network. This module does not create or manage the gateway, so provision and attach it before creating the cluster (for example, with `ovh-network`). The module discovers the network and subnet but does not validate that a gateway is attached.

The `kubeconfig` output contains credentials and is marked sensitive. Protect Terraform state and plan files, and do not commit or distribute the kubeconfig as plain text.

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | >= 2.23.0, < 3.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | 2.25.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [ovh_cloud_project_kube.production](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube) | resource |
| [ovh_cloud_project_kube_nodepool.production](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_nodepool) | resource |
| [ovh_cloud_project_network_private_subnets.subnets](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_network_private_subnets) | data source |
| [ovh_cloud_project_network_privates.networks](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_network_privates) | data source |
| [ovh_cloud_project_regions.regions](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_project_regions) | data source |
| [ovh_cloud_projects.projects](https://registry.terraform.io/providers/ovh/ovh/latest/docs/data-sources/cloud_projects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_anti_affinity"></a> [anti\_affinity](#input\_anti\_affinity) | Enable anti-affinity for instances in each node pool. | `bool` | n/a | yes |
| <a name="input_attach_floating_ips"></a> [attach\_floating\_ips](#input\_attach\_floating\_ips) | Attach OVHcloud Floating IPs to nodes in each node pool. Unsupported when disable\_public\_networking = true. | `bool` | `false` | no |
| <a name="input_autoscale"></a> [autoscale](#input\_autoscale) | Enable autoscaling for each node pool. | `bool` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Managed Kubernetes cluster. | `string` | n/a | yes |
| <a name="input_cluster_plan"></a> [cluster\_plan](#input\_cluster\_plan) | MKS cluster plan, such as free or standard. | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Managed Kubernetes cluster version. | `string` | n/a | yes |
| <a name="input_disable_public_networking"></a> [disable\_public\_networking](#input\_disable\_public\_networking) | Disable public exposure of nodes and workloads. Only supported for Standard clusters and must be set at cluster creation. | `bool` | `false` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Exact name of the existing private network to attach to the cluster. | `string` | n/a | yes |
| <a name="input_node_flavor"></a> [node\_flavor](#input\_node\_flavor) | Worker node flavor available in the selected region. | `string` | n/a | yes |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Cluster node pools with non-negative integer capacities where min\_nodes <= desired\_nodes <= max\_nodes; an empty availability\_zones list leaves zone placement unspecified. | <pre>map(object({<br/>    desired_nodes      = number<br/>    min_nodes          = number<br/>    max_nodes          = number<br/>    availability_zones = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional Public Cloud project ID or service\_name; takes precedence over project\_name. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Optional Public Cloud project name; matched against OVHcloud project\_name and description. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | OVHcloud region for the cluster. | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR of the existing subnet Kubernetes will use, for example 10.20.0.0/16. | `string` | n/a | yes |
| <a name="input_update_policy"></a> [update\_policy](#input\_update\_policy) | Managed Kubernetes cluster update policy. | `string` | `"MINIMAL_DOWNTIME"` | no |
| <a name="input_use_user_gateway"></a> [use\_user\_gateway](#input\_use\_user\_gateway) | Route node traffic through the gateway announced by the nodes subnet. Requires disable\_public\_networking = true and a Standard cluster. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Managed Kubernetes cluster ID. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Managed Kubernetes cluster name. |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status reported by OVHcloud; expected to be READY after creation. |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig for connecting to the cluster. Treat as a secret. |
| <a name="output_network_openstack_ids"></a> [network\_openstack\_ids](#output\_network\_openstack\_ids) | OpenStack network IDs matching the cluster region. |
| <a name="output_nodepool_ids"></a> [nodepool\_ids](#output\_nodepool\_ids) | Node pool IDs keyed by the corresponding node\_pools map key. |
| <a name="output_selected_networks"></a> [selected\_networks](#output\_selected\_networks) | Private network records matching network\_name in the selected project. |
| <a name="output_selected_subnets"></a> [selected\_subnets](#output\_selected\_subnets) | Subnet records matching subnet\_cidr and the cluster region. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | OVHcloud Public Cloud service name resolved for the selected project. |

## Import and Lifecycle

The module manages these Terraform resources:

- Cluster: `module.ovh_mks.ovh_cloud_project_kube.production`
- Node pool: `module.ovh_mks.ovh_cloud_project_kube_nodepool.production["<pool-key>"]`

The addresses above assume the caller names the module `ovh_mks`; use the actual module block name in your Terraform state.

To import an existing cluster, use the OVHcloud Public Cloud `service_name` and cluster ID:

```sh
terraform import 'module.ovh_mks.ovh_cloud_project_kube.production' '<service_name>/<cluster_id>'
```

To import a node pool, use its `service_name`, cluster ID, and pool ID. Repeat for each pool, replacing `<pool-key>` with the key from `node_pools`:

```sh
terraform import 'module.ovh_mks.ovh_cloud_project_kube_nodepool.production["<pool-key>"]' '<service_name>/<cluster_id>/<pool_id>'
```

Destroying the module deletes its managed node pools and MKS cluster; it does not delete the separately managed private network, subnet, or gateway. Changing the selected network/subnet, cluster region, `disable_public_networking`, or `use_user_gateway` can replace/reset the cluster and delete its data. OVHcloud currently does not implement in-place migration between the `free` and `standard` plans, so do not assume changing `cluster_plan` will upgrade an existing cluster.

Before destructive changes, migrate workloads and back up any data that must be retained, including persistent-volume data according to its storage lifecycle. Review the Terraform plan carefully before applying cluster, pool, or network changes.

## Examples

The examples are self-contained Terraform configurations that call this module:

- [Paris multi-zone](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks/_examples/multi-zone) — standard cluster with one node pool per availability zone.
- [Gravelines single pool](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks/_examples/single-pool) — standard cluster with one pool and no zone pinned.
- [Free cluster without workers](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks/_examples/free-no-workers) — free control plane and a node pool scaled to zero.

## Resources

- **OVHcloud Managed Kubernetes Service**: [Product documentation](https://www.ovhcloud.com/en/public-cloud/kubernetes/)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_kube`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube) and [`ovh_cloud_project_kube_nodepool`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube\_nodepool)
- **OVHcloud Terraform provider data sources**: [Provider documentation](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- **OVHcloud private network module**: [`ovh-network`](https://github.com/prefapp/tfm/tree/main/modules/ovh-network)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->