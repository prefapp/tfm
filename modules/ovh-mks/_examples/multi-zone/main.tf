module "ovh_mks" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mks?ref=ovh-mks-vx.y.z"

  project_name    = "example-project"
  cluster_name    = "example-mks-par"
  cluster_plan    = "standard"
  region          = "EU-WEST-PAR"
  cluster_version = "<supported-version>"

  # Create this network and subnet first, for example with modules/ovh-network.
  network_name = "example-par-private-network"
  subnet_cidr  = "10.40.0.0/16"

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

output "cluster_id" {
  description = "OVHcloud MKS cluster ID."
  value       = module.ovh_mks.cluster_id
}

output "kubeconfig" {
  description = "Sensitive cluster credentials; protect state and output."
  value       = module.ovh_mks.kubeconfig
  sensitive   = true
}
