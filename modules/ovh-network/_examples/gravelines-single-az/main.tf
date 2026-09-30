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

# Feed these outputs into the corresponding inputs of an ovh-mks caller.
output "network_openstack_id" {
  description = "Regional network ID to configure on the MKS cluster."
  value       = module.ovh_network.network_openstack_id
}

output "subnet_id" {
  description = "Subnet ID to configure on the MKS cluster."
  value       = module.ovh_network.subnet_id
}
