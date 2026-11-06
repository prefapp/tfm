# Minimal registry: SMALL plan in Gravelines, open to any source IP.
# The ovh provider is configured by the caller (environment variables or a
# provider block), not by this module.
module "ovh_container_registry" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-container-registry?ref=ovh-container-registry-vx.y.z"

  project_name = "example-project"
  name         = "example-registry"
  region       = "GRA"
  plan_name    = "SMALL"

  # The OKMS must already exist; the Harbor admin credentials are stored there
  # at <name>/<admin_login>, here example-registry/root.
  kms_id      = "<okms-id>"
  admin_login = "root"
  admin_email = "platform@example.com"
}

output "registry_url" {
  description = "Harbor UI, API and image endpoint."
  value       = module.ovh_container_registry.registry_url
}

# Pass these outputs to the harbor submodule, applied in a separate state.
output "admin_secret_path" {
  description = "KMS path of the Harbor admin credentials."
  value       = module.ovh_container_registry.admin_secret_path
}
