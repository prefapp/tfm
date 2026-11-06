resource "ovh_cloud_project_containerregistry" "registry" {
  service_name = local.service_name
  plan_id      = data.ovh_cloud_project_capabilities_containerregistry_filter.plan.id
  region       = var.region
  name         = var.name
}

# Local Harbor admin used by the harbor submodule to manage projects and robots.
# OVHcloud IAM is intentionally not enabled on the registry: enabling it deletes
# every local Harbor user, including this one. See docs/adr/0001.
resource "ovh_cloud_project_containerregistry_user" "admin" {
  service_name = ovh_cloud_project_containerregistry.registry.service_name
  registry_id  = ovh_cloud_project_containerregistry.registry.id
  login        = var.admin_login
  email        = var.admin_email
}

resource "ovh_okms_secret" "admin" {
  okms_id = data.ovh_okms_resource.kms.id
  path    = "${var.name}/${var.admin_login}"

  metadata = {
    max_versions             = 10
    deactivate_version_after = "0s"
    custom_metadata = merge(var.secret_custom_metadata, {
      registry = var.name
    })
  }

  version = {
    data = jsonencode({
      username = ovh_cloud_project_containerregistry_user.admin.user
      password = ovh_cloud_project_containerregistry_user.admin.password
      email    = ovh_cloud_project_containerregistry_user.admin.email
    })
  }
}

resource "ovh_cloud_project_containerregistry_ip_restrictions_management" "management" {
  count = length(var.ip_restrictions_management) > 0 ? 1 : 0

  service_name    = ovh_cloud_project_containerregistry.registry.service_name
  registry_id     = ovh_cloud_project_containerregistry.registry.id
  ip_restrictions = var.ip_restrictions_management
}

resource "ovh_cloud_project_containerregistry_ip_restrictions_registry" "registry" {
  count = length(var.ip_restrictions_registry) > 0 ? 1 : 0

  service_name    = ovh_cloud_project_containerregistry.registry.service_name
  registry_id     = ovh_cloud_project_containerregistry.registry.id
  ip_restrictions = var.ip_restrictions_registry
}
