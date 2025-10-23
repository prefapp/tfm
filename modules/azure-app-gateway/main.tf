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
      name                                = lookup(ssl_profile.value, "name", null)
      trusted_client_certificate_names    = lookup(ssl_profile.value, "trusted_client_certificate_names", null)
      verify_client_cert_issuer_dn        = lookup(ssl_profile.value, "verify_client_cert_issuer_dn", false)
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

  trusted_client_certificate {
      name = "foo"
      data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZnekNDQTJ1Z0F3SUJBZ0lQWFpPTk1HYzJ5QVlkR3NkVWhHa0hNQTBHQ1NxR1NJYjNEUUVCQ3dVQU1Ec3gKQ3pBSkJnTlZCQVlUQWtWVE1SRXdEd1lEVlFRS0RBaEdUazFVTFZKRFRURVpNQmNHQTFVRUN3d1FRVU1nVWtGSgpXaUJHVGsxVUxWSkRUVEFlRncwd09ERXdNamt4TlRVNU5UWmFGdzB6TURBeE1ERXdNREF3TURCYU1Ec3hDekFKCkJnTlZCQVlUQWtWVE1SRXdEd1lEVlFRS0RBaEdUazFVTFZKRFRURVpNQmNHQTFVRUN3d1FRVU1nVWtGSldpQkcKVGsxVUxWSkRUVENDQWlJd0RRWUpLb1pJaHZjTkFRRUJCUUFEZ2dJUEFEQ0NBZ29DZ2dJQkFMcHhnSHBNaG01Lwp5Qk50d01aOUhBQ1hqeXdNSTdzUW1rQ3BHcmVIaVBpYlZtcjc1bnVPaTVLT3B5VmRXUkhiTmk2M1VSY2ZxUWdmCkJCY2tXS28zU2hqZjVUblVWLzNYd1N5UkFaSGlJdFFEd0ZqOGQwZnNqejUwUTdxc05JMU5PSFpuanJESWJ6QXoKV0hGY3RQVnJidFFCVUxnVGZteEtvMG5SSUJudXZNQXBHR1duM3Y3djNRcVFJZWNhWjVKQ0VKaGZUekM4UGh4Rgp0QkRYYUVBVXdFRDY1M2NYZXVZTGoyVmJQTm1hVXR1MXZaNUd6ejNya1FVQ3dKYXlka3hORUpZN2t2cWNmdytaCjM3NGpOVVVlQWx6K3RhaWJtU1hhWHZNaXd6bjE1Q291MDhZZnhHeXF4UnhxQVFWS0w5TEZ3YWcwSmwxbXBkSUMKSWZrWXR3YjFUcGx2cUt0TVVlalBVQmpGZDhnNUNTeEpraktacUxzWEYzbXdXc1htbzhSWlpVYzFnMTZwNkRVTAptYnZrelNER20wb0dPYlZvL0NLNjdsV01LMDdxODdIai9MYVptdFZDK25GTkNNK0hIbXB4ZmZuVHRPbWxjWUY3CndrNUhscVgyZG9XaktJL3BnRzZCVTZWdFg3aEkrY0w1TnFZdVNmKzRsc0tNQjdPYmlGajg2eHNjM2kxdzRwZVMKTUtHSjQ3eFZxQ2ZXUysyUXJZdjZZeVZaTGFnMTNjcVhNN3psemNlZDBlenZYZzVLa0FZbVk2MjUyVFV0QjdwMgpaU3lzVjQ5OTlBZVUxNEVDbGwyakIwblZldEJYK1J2blUwWjFxckI1UXN0b2NRanBZTDA1YWM3MHI4TldRTWV0ClVxSUo1RytHUjRvZjZ5Z25YWU1ncndUSmJGYWFpMGIxQWdNQkFBR2pnWU13Z1lBd0R3WURWUjBUQVFIL0JBVXcKQXdFQi96QU9CZ05WSFE4QkFmOEVCQU1DQVFZd0hRWURWUjBPQkJZRUZQZDl4ZjNFNkpvYmQyU245UjJnekwrSApZSnB0TUQ0R0ExVWRJQVEzTURVd013WUVWUjBnQURBck1Da0dDQ3NHQVFVRkJ3SUJGaDFvZEhSd09pOHZkM2QzCkxtTmxjblF1Wm01dGRDNWxjeTlrY0dOekx6QU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FnRUFCNUJLMy9NalR2REQKbkZGbG01d2lvb29NaGZOektXdE4vZ0hpcVF4akFiOEVaNldkbUYvOUFSUDY3SnBpNlliK3RtTFNia3lVKzhCMQpSWHhsRFBpeU44K3NEOCtOYi9rWjk0L3NIdkp3bnZES3VPKzMvM1kzZGx2MmJvanpyMkl5SXBNTk9tcU9GR1lNCkxWTjBWMlVlMWJMZEk0RTdwV1lqSjJjSmorRjNxa1BOWlZFSTdWRlkvdVk1K2N0SGhLUVY4WGE3cE82a084UmYKNzdJemxoRVl0OGxsdmhqaG82VGMraGo1MDd3VG16bDZOTHJUUWZ2Nk1vb3F0eXVHQzJtRE9MN05paTRMY0syTgpKcEx1SHZVQkt3cloxcGViYnVDb0dSdzZJWXNNSGtDdEErZmRabjcxdVNBTkEraVcrWUpGMURuZ29BQmQxNWptCmZaNW5jOE9hS3Zlcmk2RTZGTzgwdkZJT2laaWFCRUNFSFg1RmFaTlh6dXZPK0ZCOFR4eHVCRU9iK2RZN0l4anAKNm83UlRVYU44VHZrYXNxNit5TzNtL3FaQVNsYVdGb3Q0L25VYlE0bXJjRnVOTHd5K0F3RittV2oyenMzZ3lMcAoxdHh5TS8xZDhpQzlkandqMmlqMytSdnJXV1RWM0Y5eWZpRDh6WW0xa0dkTlluby9UcTBkd3puK2V2UW9GdDlCCjlraUFCZGNQVVhtc0VLdlU3QU5tNW1xd3VqR1NRa0JxdmpyVGN1RnFOMVc4ckIyVnQybGg4a09SZE9hZzB3b2sKUnFFSXI5YmFSUm1XMUZNZFc0UjU4TUQzUisrTGo4VUdycDFNWXAzL1JnVDQwOG0yRUNWQWRmNFdxc2xLWUlZdgp1dTh3ZCtSVTRyaUVtVmlBcWhPTFVUcFBTUGFMdHJNPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
