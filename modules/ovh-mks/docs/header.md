> [!WARNING]
> **Avoid MKS-reserved private network CIDRs.** Do not use these ranges in the private network attached to your cluster:
>
> - **Free plan:** `10.2.0.0/16`, `10.3.0.0/16`, and `172.17.0.0/16`.
> - **Standard plan:** `10.240.0.0/13` and `10.3.0.0/16`.
>
> Standard plan pod and service ranges can be customized when creating or resetting a cluster. Changing them on a running cluster requires a reset and can cause data loss. See [OVHcloud MKS known limits](https://docs.ovhcloud.com/en/guides/public-cloud/containers-orchestration/managed-kubernetes/known-limits/).

# **OVHcloud Managed Kubernetes Service (MKS) Terraform Module**

## Overview

This module provisions an OVHcloud Managed Kubernetes Service (MKS) cluster and its node pools in an existing Public Cloud project. It discovers the project, private network, and subnet from the supplied project selector, network name, subnet CIDR, and cluster region; the network and subnet are not created by this module.

Use it for a free control-plane cluster, a single-region cluster with one pool, or a standard multi-zone cluster with separate pools per availability zone. The cluster's Kubernetes version and update policy are configurable, and node pools support desired/minimum/maximum capacity, autoscaling, anti-affinity, and availability-zone placement.

## Key Features

- **Managed cluster**: Provisions an OVHcloud MKS cluster with a selected region, plan, Kubernetes version, and update policy.
- **Existing-network discovery**: Selects the private network by exact name and subnet by CIDR in the cluster region.
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
    zone_a = {
      desired_nodes      = 1
      min_nodes          = 1
      max_nodes          = 3
      availability_zones = ["eu-west-par-a"]
    }
    zone_b = {
      desired_nodes      = 0
      min_nodes          = 0
      max_nodes          = 3
      availability_zones = ["eu-west-par-b"]
    }
    zone_c = {
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

The `kubeconfig` output contains credentials and is marked sensitive. Protect Terraform state and plan files, and do not commit or distribute the kubeconfig as plain text.
