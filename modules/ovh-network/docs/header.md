> [!WARNING]
> **Avoid MKS-reserved private network CIDRs.** If this network will be attached to an OVHcloud MKS cluster, do not use these ranges for `network_cidr`:
>
> - **Free plan:** `10.2.0.0/16`, `10.3.0.0/16`, and `172.17.0.0/16`.
> - **Standard plan:** `10.240.0.0/13` and `10.3.0.0/16`.
>
> Standard plan pod and service ranges can be customized when creating or resetting a cluster. Changing them on a running cluster requires a reset and can cause data loss. See [OVHcloud MKS known limits](https://docs.ovhcloud.com/en/guides/public-cloud/containers-orchestration/managed-kubernetes/known-limits/).

# **OVHcloud Private Network Terraform Module**

## Overview

This Terraform module creates an OVHcloud Public Cloud private network, a DHCP-enabled subnet, and a Public Cloud gateway in one selected region. It can be used as a reusable network foundation for workloads that need private connectivity and outbound access through an OVHcloud gateway.

The module can also create network infrastructure for an OVHcloud Managed Kubernetes Service (MKS) cluster. The network and subnet are managed independently from the cluster, and their IDs are exposed as outputs for consumers that accept IDs directly. The `ovh-mks` module instead discovers an existing network by exact name and its subnet by CIDR in the selected project and region; pass the same `network_name` and CIDR to that module. The network itself is regional and does not configure or select availability zones.

The Public Cloud project can be selected by `project_name` or by `project_id` (which also accepts the OVHcloud `service_name` and takes precedence when set).

## Key Features

- **Private network provisioning**: Creates a private network in the selected OVHcloud Public Cloud region with a configurable name and VLAN ID.
- **DHCP subnet**: Creates a subnet with a configurable CIDR and DHCP address-pool range.
- **Public Cloud gateway**: Creates a gateway attached to the new network and subnet using the requested gateway model.
- **Flexible project selection**: Resolves the Public Cloud project by name or by project ID/service name.
- **MKS-ready outputs**: Exposes the regional network ID and subnet ID required when configuring an MKS cluster.

## Basic Usage

Use a released module tag in the Git source. Replace the example project, network, CIDR, VLAN, region, and gateway model with values supported by your OVHcloud account. Configure OVHcloud credentials using the provider's supported authentication methods; do not put credentials in these examples.

### Network for a single-AZ MKS scenario in Gravelines

This creates regional networking resources for a workload or MKS cluster in Gravelines. The single-AZ placement is configured later on the MKS cluster and is not managed by this module.

```hcl
module "ovh_network" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-network?ref=ovh-network-vx.y.z"

  project_name      = "example-project"
  network_name      = "example-gra-private-network"
  gateway_name      = "example-gra-gateway"
  region            = "GRA11"
  vlan_id           = 101
  network_cidr      = "10.41.0.0/16"
  subnet_pool_start = "10.41.0.10"
  subnet_pool_end   = "10.41.255.254"
  gateway_model     = "<available-gateway-model>"
}
```

### Network for a three-AZ MKS scenario in Paris

The same regional network can serve an MKS cluster whose node pools are placed across three Paris availability zones. Configure those zones on the MKS cluster, not on this network module.

```hcl
module "ovh_network" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-network?ref=ovh-network-vx.y.z"

  project_name      = "example-project"
  network_name      = "example-par-private-network"
  gateway_name      = "example-par-gateway"
  region            = "EU-WEST-PAR"
  vlan_id           = 102
  network_cidr      = "10.40.0.0/16"
  subnet_pool_start = "10.40.0.10"
  subnet_pool_end   = "10.40.255.254"
  gateway_model     = "<available-gateway-model>"
}
```

After applying the network configuration, configure the `ovh-mks` module with the same network name as `network_name` and the same subnet CIDR as `subnet_cidr`. The `network_openstack_id` and `subnet_id` outputs are available to other consumers that accept resource IDs directly. Complete standalone examples are linked below.
