# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
resource "azurerm_application_gateway" "application_gateway" {
  name                = var.application_gateway.name
  resource_group_name = var.resource_group_name
  location            = var.location
  enable_http2        = var.application_gateway.enable_http2

  # Max blocks: 1
  identity {
    type         = var.application_gateway.identity.type  
    identity_ids = [data.azurerm_user_assigned_identity.that.id]
  }


  # Max blocks: 1
  sku {
    name     = var.application_gateway.sku.name
    tier     = var.application_gateway.sku.tier
    capacity = var.application_gateway.sku.capacity
  }

  # Max blocks: 1
  autoscale_configuration {
    min_capacity = var.application_gateway.autoscale_configuration.min_capacity
    max_capacity = var.application_gateway.autoscale_configuration.max_capacity
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.default_waf_policy.id

  # Max blocks: 2
  gateway_ip_configuration {
    name      = var.application_gateway.gateway_ip_configuration.name
    subnet_id = data.azurerm_subnet.that.id
  }

  dynamic "frontend_port" {
    for_each = var.application_gateway.frontend_ports
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  frontend_ip_configuration {
    name                          = var.application_gateway.frontend_ip_configuration.name
    private_ip_address_allocation = var.application_gateway.frontend_ip_configuration.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  dynamic "backend_address_pool" {
    for_each = local.backend_address_pools
    content {
      name         = lookup(backend_address_pool.value,"name", null)
      ip_addresses = lookup(backend_address_pool.value,"ip_addresses", null)
      fqdns        = lookup(backend_address_pool.value,"fqdns", null)
    }
  }

  dynamic "backend_http_settings" {
    for_each = local.backend_http_settings
    content {
      name                                = lookup(backend_http_settings.value, "name", null)
      cookie_based_affinity               = lookup(backend_http_settings.value, "cookie_based_affinity", null)
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", null)
      port                                = lookup(backend_http_settings.value, "port", null)
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      protocol                            = lookup(backend_http_settings.value, "protocol", null)
      request_timeout                     = lookup(backend_http_settings.value, "request_timeout", null)
      trusted_root_certificate_names      = lookup(backend_http_settings.value, "trusted_root_certificate_names", null)
    }
  }

  dynamic "http_listener" {
    for_each = local.http_listeners
    content {
      name                           = lookup(http_listener.value ,"name", null)
      frontend_ip_configuration_name = lookup(http_listener.value ,"frontend_ip_configuration_name", null)
      frontend_port_name             = lookup(http_listener.value ,"frontend_port_name", null)
      host_names                     = lookup(http_listener.value ,"host_names", null)
      protocol                       = lookup(http_listener.value ,"protocol", null)
      require_sni                    = lookup(http_listener.value ,"require_sni", null)
      ssl_certificate_name           = lookup(http_listener.value ,"ssl_certificate_name", null)
      ssl_profile_name               = lookup(http_listener.value ,"ssl_profile", null)
    }
  }

  dynamic "probe" {
    for_each = local.probes
    content {
      name                                      = lookup(probe.value, "name", null)
      host                                      = lookup(probe.value, "host", null)
      interval                                  = lookup(probe.value, "interval", null)
      minimum_servers                           = lookup(probe.value, "minimum_servers", null)
      path                                      = lookup(probe.value, "path", null)
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", null)
      protocol                                  = lookup(probe.value, "protocol", null)
      timeout                                   = lookup(probe.value, "timeout", null)
      unhealthy_threshold                       = lookup(probe.value, "unhealthy_threshold", null)
      dynamic "match" {
        for_each = probe.value.matches
        content {
          status_code = match.value.status_code
        }
      }
    }
  }

  dynamic "redirect_configuration" {
    for_each = local.redirect_configurations
    content {
      name                 = lookup(redirect_configuration.value, "name", null)
      include_path         = lookup(redirect_configuration.value, "include_path", null)
      include_query_string = lookup(redirect_configuration.value, "include_query_string", null)
      redirect_type        = lookup(redirect_configuration.value, "redirect_type", null)
      target_listener_name = lookup(redirect_configuration.value, "target_listener_name", null)
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.request_routing_rules
    content {
      name                        = lookup(request_routing_rule.value, "name", null) 
      http_listener_name          = lookup(request_routing_rule.value, "http_listener_name", null) 
      priority                    = lookup(request_routing_rule.value, "priority", null) 
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null) 
      rule_type                   = lookup(request_routing_rule.value, "rule_type", null) 
      backend_address_pool_name   = lookup(request_routing_rule.value, "backend_address_pool_name", null) 
      backend_http_settings_name  = lookup(request_routing_rule.value, "backend_http_settings_name", null) 
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.application_gateway.ssl_certificates
    content {
      name               = lookup(ssl_certificate.value, "name", null)
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }

  dynamic "ssl_profile" {
    for_each = local.ssl_profiles
    content {
      name                                 = lookup(ssl_profile.value, "name", null)
      trusted_client_certificate_names     = [for certName, certData in data.external.cert_content_base64 : certName if certData.result.ca-dir == ssl_profile.value.ca_certs_origin.github_directory]
      verify_client_cert_issuer_dn         = lookup(ssl_profile.value, "verify_client_cert_issuer_dn", false)
      verify_client_certificate_revocation = lookup(ssl_profile.value, "verify_client_certificate_revocation", null)
      dynamic "ssl_policy" {
        for_each = lookup(ssl_profile.value, "ssl_policy", null) == null ? [] : [ssl_profile.value.ssl_policy]
        content {
          disabled_protocols   = lookup(ssl_policy.value, "disabled_protocols", null)
          min_protocol_version = lookup(ssl_policy.value, "min_protocol_version", null)
          policy_name          = lookup(ssl_policy.value, "policy_name", null)
          cipher_suites        = lookup(ssl_policy.value, "cipher_suites", null)
        }
      }
    }
  }

  dynamic "trusted_client_certificate" {
    for_each = data.external.cert_content_base64.result
    content {
      name = trusted_client_certificate.key
      data = trusted_client_certificate.value
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
