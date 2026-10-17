module "ovh_mks" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-mks?ref=ovh-mks-vx.y.z"

  project_name    = "example-project"
  cluster_name    = "example-mks-gra"
  cluster_plan    = "standard"
  region          = "GRA11"
  cluster_version = "<supported-version>"

  # Create this network and subnet first, for example with modules/ovh-network.
  network_name = "example-gra-private-network"
  subnet_cidr  = "10.41.0.0/16"

  node_flavor   = "<available-flavor>"
  autoscale     = true
  anti_affinity = true

  node_pools = {
    main = {
      desired_nodes      = 2
      min_nodes          = 2
      max_nodes          = 5
      availability_zones = [] # Leave placement to OVHcloud.
    }
  }
}

output "cluster_name" {
  description = "OVHcloud MKS cluster name."
  value       = module.ovh_mks.cluster_name
}
