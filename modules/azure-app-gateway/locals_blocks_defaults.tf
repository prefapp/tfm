locals {

  blocks_defaults = var.application_gateway.blocks_defaults

  ssl_profiles = var.ssl_profiles

  trusted_client_certificates = [
    for cert_file in fileset(path.module, "ca-certs/*.cer") : {
      name = cert_file
      data = filebase64("${path.module}/${cert_file}")
    }
  ]

}
