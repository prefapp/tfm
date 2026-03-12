## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.47.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.47.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.application_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/resources/public_ip) | resource |
| [azurerm_web_application_firewall_policy.default_waf_policy](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/resources/web_application_firewall_policy) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.that](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/data-sources/subnet) | data source |
| [azurerm_user_assigned_identity.that](https://registry.terraform.io/providers/hashicorp/azurerm/4.47.0/docs/data-sources/user_assigned_identity) | data source |
| [external_external.cert_content_base64](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.list_cert_files](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_gateway"></a> [application\_gateway](#input\_application\_gateway) | The Application Gateway object. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the Application Gateway should be created. | `string` | `"westeurope"` | no |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | The Azure Public IP object. | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Application Gateway. | `string` | n/a | yes |
| <a name="input_rewrite_rule_sets"></a> [rewrite\_rule\_sets](#input\_rewrite\_rule\_sets) | List of Rewrite Rule Sets for Application Gateway | <pre>list(object({<br/>    name = string<br/>    rewrite_rules = list(object({<br/>      name          = string<br/>      rule_sequence = number<br/>      conditions = optional(list(object({<br/>        variable    = string<br/>        pattern     = string<br/>        ignore_case = optional(bool, false)<br/>        negate      = optional(bool, false)<br/>      })), [])<br/>      request_header_configurations = optional(list(object({<br/>        header_name  = string<br/>        header_value = string<br/>      })), [])<br/>      response_header_configurations = optional(list(object({<br/>        header_name  = string<br/>        header_value = string<br/>      })), [])<br/>      url_rewrite = optional(object({<br/>        source_path = optional(string)<br/>        query_string = optional(string)<br/>        components = optional(string)<br/>        reroute = optional(bool)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | Application Gateway configuration | <pre>object({<br/>    policy_type          = string<br/>    policy_name          = optional(string)<br/>    cipher_suites        = optional(list(string))<br/>    min_protocol_version = optional(string)<br/>  })</pre> | <pre>{<br/>  "policy_name": "AppGwSslPolicy20220101",<br/>  "policy_type": "Predefined"<br/>}</pre> | no |
| <a name="input_ssl_profiles"></a> [ssl\_profiles](#input\_ssl\_profiles) | List of SSL profiles for Application Gateway. | <pre>list(object({<br/>    name                                     = string<br/>    trusted_client_certificate_names         = optional(list(string))<br/>    verify_client_cert_issuer_dn             = optional(bool, false)<br/>    verify_client_certificate_revocation     = optional(string)<br/>    ssl_policy = optional(object({<br/>      disabled_protocols                     = optional(list(string))<br/>      min_protocol_version                   = optional(string)<br/>      policy_name                            = optional(string)<br/>      cipher_suites                          = optional(list(string))<br/>    }))<br/>    ca_certs_origin = object({<br/>      github_owner       = string<br/>      github_repository  = string<br/>      github_branch      = string<br/>      github_directory   = string<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The subnet object. | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_user_assigned_identity"></a> [user\_assigned\_identity](#input\_user\_assigned\_identity) | The name of the User Assigned Identity. | `string` | n/a | yes |
| <a name="input_web_application_firewall_policy"></a> [web\_application\_firewall\_policy](#input\_web\_application\_firewall\_policy) | Configuration for the web application firewall policy | <pre>object({<br/>    name = string<br/>    policy_settings = optional(object({<br/>      enabled                     = optional(bool)<br/>      mode                        = optional(string)<br/>      request_body_check          = optional(bool)<br/>      file_upload_limit_in_mb     = optional(number)<br/>      max_request_body_size_in_kb = optional(number)<br/>      request_body_enforcement    = optional(string)<br/>    }))<br/>    custom_rules = optional(list(object({<br/>      enabled               = optional(bool, true)<br/>      name                  = string<br/>      priority              = number<br/>      rule_type             = string<br/>      action                = string<br/>      rate_limit_duration   = optional(string)<br/>      rate_limit_threshold  = optional(number)<br/>      group_rate_limit_by   = optional(string)<br/>      match_conditions      = list(object({<br/>        operator           = string<br/>        negation_condition = optional(bool, false)<br/>        match_values       = optional(list(string))<br/>        transforms         = optional(list(string))<br/>        match_variables    = list(object({<br/>          variable_name = string<br/>          selector      = optional(string)<br/>        }))<br/>      }))<br/>    })), [])<br/>    managed_rule_set = list(object({<br/>      type                = optional(string)<br/>      version             = string<br/>      rule_group_override = optional(list(object({<br/>        rule_group_name = string<br/>        rule = optional(list(object({<br/>          id      = number<br/>          enabled = optional(bool)<br/>          action  = optional(string)<br/>        })))<br/>      })))<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Application Gateway. |

## Example

```yaml
    values:
      # Data values
      tags_from_rg: true
      resource_group_name: ${{ tfworkspace:example-rg:outputs.resource_group_name }}
      user_assigned_identity: "example-identity"

      subnet:
        name: "example-subnet"
        virtual_network_name: "example-vnet"

      # Public IP
      public_ip:
        name: "example-public-ip"
        sku: "Standard"
        allocation_method: "Static"
        
      # SSL Profiles
      ssl_profiles:
        - name: "example-ssl-profile"
          verify_client_cert_issuer_dn: true
          verify_client_certificate_revocation: "OCSP"
          ssl_policy:
            disabled_protocols:
              - "TLSv1_0"
              - "TLSv1_1"
            min_protocol_version: "TLSv1_2"
            policy_name: "AppGwSslPolicy20170401S"
            cipher_suites:
              - "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
              - "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
          ca_certs_origin:
            github_owner: "gh-owner"
            github_repository: "gh-repo"
            github_branch: "gh-branch"
            github_directory: "gh-dir"

      # Rewrite Rule Sets
      rewrite_rule_sets:
        - name: example-rewrite
          rewrite_rules:
            - name: example-rule
              rule_sequence: 300
              conditions:
                - variable: http_request_uri
                  pattern: '.*\.html$'
                  ignore_case: true
                  negate: false
                - variable: http_request_method
                  pattern: '^POST$'
                  ignore_case: true
                  negate: true
              request_header_configurations:
                - header_name: X-Rewrite-Rule
                  header_value: applied
              response_header_configurations:
                - header_name: X-Cache-Control
                  header_value: max-age=3600
                - header_name: X-Server
                  header_value: custom-app
              url_rewrite:
                source_path: '^/api/v1/(.*)'
                components: path_only # Only possible values "path_only" or "query_string_only", if using both leave null
                reroute: false

      # WAF
      web_application_firewall_policy:
        name: "example-waf-policy"
        policy_settings:
          enabled: true
          mode: "Detection"
          request_body_check: true
          file_upload_limit_in_mb: 100
          max_request_body_size_in_kb: 128
        custom_rules:
          - name: "HeaderName"
            enabled: true
            priority: 1
            rule_type: "MatchRule"
            action: "Allow"
            match_conditions:
              - match_values:
                  - "example.com"
                operator: "Equal"
                match_variables:
                  - variable_name: "RequestHeaders"
                    selector: "Host"
        - name: "BlockUserAgentWindows"
          enabled: true
          priority: 2
          rule_type: "MatchRule"
          action: "Block"
          match_conditions:
            - operator: "Contains"
              negation_condition: false
              match_values:
                - "Windows"
              match_variables:
                - variable_name: "RequestHeaders"
                  selector: "UserAgent"
        managed_rule_set:
          - type: "OWASP"
            version: "3.2"
            rule_group_override:
              - rule_group_name: "REQUEST-932-APPLICATION-ATTACK-RCE"
                rule:
                  - id: "932100"
                    action: "AnomalyScoring"
                    enabled: false
                  - id: "932110"
                    action: "AnomalyScoring"
                    enabled: false
              - rule_group_name: "REQUEST-942-APPLICATION-ATTACK-SQLI"
                rule:
                  - id: "942430"
                    action: "AnomalyScoring"
                    enabled: false
          - type: "Microsoft_BotManagerRuleSet"
            version: "0.1"
      # AppGW
      application_gateway:
        name: "example-appgw"
        identity:
          type: "UserAssigned"
        enable_http2: true
        sku:
          name: "WAF_v2"
          tier: "WAF_v2"
          capacity: 0
        gateway_ip_configuration:
          name: "appGatewayIpConfig"
        autoscale_configuration:
          min_capacity: 0
          max_capacity: 10
        frontend_ports:
          - name: "port_80"
            port: 80
          - name: "port_443"
            port: 443
        frontend_ip_configuration:
          name: "appGwPublicFrontendIpIPv4"
          private_ip_address_allocation: "Dynamic"
        ssl_certificates:
          - name: "example-cert-1"
            key_vault_secret_id: "https://example-kv.vault.azure.net/secrets/example-cert-1"
          - name: "example-cert-2"
            key_vault_secret_id: "https://example-kv.vault.azure.net/secrets/example-cert-2"

        # Default blocks configuration
        blocks_defaults:
          backend_http_settings:
            cookie_based_affinity: "Disabled"
            pick_host_name_from_backend_address: false
            port: 80
            protocol: "Http"
            request_timeout: 20
            trusted_root_certificate_names: []
          http_listeners:
            https:
              frontend_ip_configuration_name: "appGwPublicFrontendIpIPv4"
              frontend_port_name: "port_443"
              protocol: "Https"
              ssl_certificate_name: "example-cert-2"
              ssl_profile_name: "example-ssl-profile"
            http-redirection:
              frontend_ip_configuration_name: "appGwPublicFrontendIpIPv4"
              frontend_port_name: "port_80"
              protocol: "Http"
              require_sni: false
          probe:
            host: "10.0.0.1"
            interval: 10
            minimum_servers: 0
            path: "/"
            pick_host_name_from_backend_http_settings: false
            protocol: "Http"
            timeout: 30
            unhealthy_threshold: 3
            matches:
              - status_code: ["200-399", "404"]
          redirect_configuration:
            include_path: true
            include_query_string: true
            redirect_type: "Permanent"
          request_routing_rules:
            http-redirection:
              rule_type: "Basic"
              rewrite_rule_set_name: example-rewrite
            https:
              rule_type: "Basic"
              rewrite_rule_set_name: example-rewrite

        # Custom blocks configuration
        blocks:
          organization1:
            app1:
              pro:
                backend_http_settings:
                  request_timeout: 90
                redirect_configuration: {}
                backend_address_pool:
                  ip_addresses:
                   - 10.0.0.2
                http_listeners:
                  https:
                    host_names:
                      - "example.com"
                    ssl_certificate_name: "example-cert-1"
                  http-redirection:
                    host_names:
                      - "example.com"
                probe:
                  host: "10.0.0.2"
                request_routing_rules:
                  http-redirection:
                    priority: 10
                    name: "redirect-example"
                    redirect_configuration_name: "redirect-example"
                  https:
                    backend_address_pool_name: "backend_address_pool-example"
                    backend_http_settings_name: "backend_http_settings-example"
                    priority: 11
                    name: "request_routing_rule-example"
          organization2:
            app1:
              pro:
                backend_http_settings:
                  request_timeout: 60
                redirect_configuration: {}
                backend_address_pool:
                  ip_addresses:
                  - 10.0.0.3
                http_listeners:
                  https:
                    host_names:
                      - "another-example.com"
                    ssl_certificate_name: "example-cert-1"
                  http-redirection:
                    host_names:
                      - "another-example.com"
                probe:
                  host: "10.0.0.3"
                request_routing_rules:
                  http-redirection:
                    priority: 20
                    name: "redirect-another-example"
                    redirect_configuration_name: "redirect-another-example"
                  https:
                    backend_address_pool_name: "backend_address_pool-another-example"
                    backend_http_settings_name: "backend_http_settings-another-example"
                    priority: 21
                    name: "request_routing_rule-another-example"
```
