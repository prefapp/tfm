output "access_matrix" {
  description = "Configured identities, authentication methods, roles, scopes, and destinations."
  value = {
    for name, identity in var.identities : name => {
      role                      = identity.role
      scope                     = identity.scope
      namespaces                = identity.scope == "cluster" ? ["*"] : sort(tolist(identity.namespaces))
      auth_methods              = sort(tolist(identity.auth_methods))
      service_account_namespace = contains(identity.auth_methods, "token") ? identity.service_account_namespace : null
      secret_paths              = identity.secret_paths
      credential_generation     = terraform_data.credential_generation[name].triggers_replace
      local_kubeconfig_paths = var.export_local_kubeconfigs ? {
        for method in identity.auth_methods : method => local_sensitive_file.kubeconfig["${name}/${method}"].filename
      } : {}
    }
  }
}

output "okms_secret_paths" {
  description = "OVH Secret Manager paths configured for each published credential."
  value = {
    for key, access in local.identity_methods : key => lookup(access.identity.secret_paths, access.method, "")
    if var.publish_to_okms
  }
}

output "service_name" {
  description = "OVHcloud service_name of the project matched by project_description."
  value       = local.service_name
}
