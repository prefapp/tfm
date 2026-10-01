locals {
  certificate_identities = {
    for name, identity in var.identities : name => identity
    if contains(identity.auth_methods, "certificate")
  }
  token_identities = {
    for name, identity in var.identities : name => identity
    if contains(identity.auth_methods, "token")
  }
  identity_methods = merge({}, [
    for identity_name, identity in var.identities : {
      for method in identity.auth_methods : "${identity_name}/${method}" => {
        identity_name = identity_name
        method        = method
        identity      = identity
      }
    }
  ]...)
  identity_methods_by_name = {
    for identity_name, identity in var.identities : identity_name => {
      for method in identity.auth_methods : method => {
        identity_name = identity_name
        method        = method
        identity      = identity
      }
    }
  }

  namespace_bindings = merge({}, [
    for identity_name, identity in var.identities : {
      for namespace in identity.namespaces : "${identity_name}/${namespace}" => {
        identity_name = identity_name
        namespace     = namespace
        role          = identity.role
        methods       = local.identity_methods_by_name[identity_name]
      }
    }
    if identity.scope == "namespaces"
  ]...)

  cluster_bindings = {
    for name, identity in var.identities : name => identity
    if identity.scope == "cluster"
  }

  missing_secret_paths = flatten([
    for identity_name, identity in var.identities : [
      for method in identity.auth_methods : "${identity_name}/${method}"
      if trimspace(lookup(identity.secret_paths, method, "")) == ""
    ]
  ])
  configured_secret_destinations = flatten([
    for identity_name, identity in var.identities : [
      for method, path in identity.secret_paths : path
      if contains(identity.auth_methods, method) && trimspace(path) != ""
    ]
  ])
}
