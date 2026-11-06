# Registry with separate allow-lists for the Harbor UI/API and for the image
# endpoint. An empty list leaves that endpoint open; a non-empty list blocks
# every source not listed, so include your CI runners and cluster egress IPs.
module "ovh_container_registry" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-container-registry?ref=ovh-container-registry-vx.y.z"

  project_id = "<public-cloud-service-name>"
  name       = "example-registry"
  region     = "GRA"
  plan_name  = "MEDIUM"

  kms_id      = "<okms-id>"
  admin_email = "platform@example.com"

  secret_custom_metadata = {
    owner = "platform-team"
  }

  # Harbor UI and API: office VPN only.
  ip_restrictions_management = [
    {
      ip_block    = "203.0.113.0/24"
      description = "Office VPN"
    },
  ]

  # docker/helm push and pull: CI runners and the Kubernetes cluster egress.
  ip_restrictions_registry = [
    {
      ip_block    = "198.51.100.10/32"
      description = "CI runners"
    },
    {
      ip_block    = "192.0.2.0/28"
      description = "Kubernetes gateway egress"
    },
  ]
}

output "registry_url" {
  description = "Harbor UI, API and image endpoint."
  value       = module.ovh_container_registry.registry_url
}
