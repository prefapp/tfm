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

# ovh-mks discovers this network by network_name and subnet_cidr; these IDs are
# available for other consumers that accept resource IDs directly.
# Configure the MKS node pools across three Paris AZs in that separate caller.
output "network_openstack_id" {
  description = "Regional OpenStack network ID for ID-based consumers."
  value       = module.ovh_network.network_openstack_id
}

output "subnet_id" {
  description = "Subnet ID for ID-based consumers."
  value       = module.ovh_network.subnet_id
}
