output "access_matrix" {
  description = "Identidades, métodos de autenticación, rol, alcance y destinos configurados."
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
  description = "Rutas de OVH Secret Manager configuradas para cada credencial publicada."
  value = {
    for key, access in local.identity_methods : key => lookup(access.identity.secret_paths, access.method, "")
    if var.publish_to_okms
  }
}

output "service_name" {
  description = "Identificador OVHcloud del proyecto encontrado por project_description."
  value       = local.service_name
}
