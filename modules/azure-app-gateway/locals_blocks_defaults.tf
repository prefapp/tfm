locals {

  blocks_defaults = var.application_gateway.blocks_defaults

  ssl_profiles = var.ssl_profiles

  trusted_client_certificates = [
    for ca_dir in "${var.ca_dirs}" :{
      for cert_file in fileset("${path.module}/${ca_dir}", "*.{pem,cer}") : { # File Regex: *.{pem,cer}" catches any file with at least one character name and whose extension is .pem or .cer
        name = "${cert_file}"
        data = filebase64("${path.module}/${ca_dir}/${cert_file}")
        dir = "${ca_dir}"
      }
    }
  ]

}
