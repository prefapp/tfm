output "service_name" {
  description = "OVHcloud Public Cloud service name resolved for the selected project."
  value       = local.service_name
}

output "registry_id" {
  description = "ID of the Managed Private Registry."
  value       = ovh_cloud_project_containerregistry.registry.id
}

output "registry_name" {
  description = "Name of the Managed Private Registry."
  value       = ovh_cloud_project_containerregistry.registry.name
}

output "registry_url" {
  description = "Access URL of the registry (Harbor UI, API and image endpoint)."
  value       = ovh_cloud_project_containerregistry.registry.url
}

output "registry_plan" {
  description = "Plan name of the registry."
  value       = ovh_cloud_project_containerregistry.registry.plan[0].name
}

output "kms_id" {
  description = "ID of the OKMS that holds the Harbor admin credentials."
  value       = data.ovh_okms_resource.kms.id
}

output "admin_secret_path" {
  description = "KMS path of the Harbor admin credentials ({username, password, email})."
  value       = ovh_okms_secret.admin.path
}
