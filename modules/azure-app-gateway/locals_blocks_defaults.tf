locals {

  blocks_defaults = var.application_gateway.blocks_defaults

  ssl_profiles = var.ssl_profiles

  trusted_client_certificates = flatten([
    for ca_dir in var.ca_dirs : {
      for cert_file in fileset("${path.module}/${ca_dir}", "*") : {
        name = cert_file
        data = filebase64("${path.module}/${ca_dir}/${cert_file}")
        dir  = ca_dir
      }
    }
  ])

}
