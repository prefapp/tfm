module "ovh_mks" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mks?ref=ovh-mks-vx.y.z"

  project_name    = "example-project"
  cluster_name    = "example-mks-free"
  cluster_plan    = "free"
  region          = "GRA11"
  cluster_version = "<supported-version>"

  # The network and subnet must exist in this project and region before applying.
  network_name = "example-gra-private-network"
  subnet_cidr  = "10.41.0.0/16"

  # A flavor is required by this module, but no worker nodes are requested here.
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

output "cluster_status" {
  description = "Managed control-plane status."
  value       = module.ovh_mks.cluster_status
}
