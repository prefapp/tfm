## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ">= 3.69.0, < 4.0" |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ">= 3.69.0, < 4.0" |

## Resources

| Name | Type |
|------|------|
| [azurerm_user_assigned_identity.that](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [azurerm_subnet.that](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_public_ip.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_application_gateway.application_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_web_application_firewall_policy.default_waf_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location/region where the Application Gateway should be created. | `string` | `"westeurope"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Application Gateway. | `string` | n/a | yes |
| <a name="input_application_gateway"></a> [application\_gateway](#input\_application\_gateway) | The Application Gateway object. | `any` | n/a | yes |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | The Azure Public IP object. | `any` | n/a | yes |
| <a name="input_user_assigned_identity"></a> [user\_assigned\_identity](#input\_user\_assigned\_identity) | The name of the User Assigned Identity. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The subnet object. | `any` | n/a | yes |
| <a name="input_web_application_firewall_policy"></a> [web\_application\_firewall\_policy](#input\_web\_application\_firewall\_policy) | Configuration for the web application firewall policy. | `object({ name = string, policy_settings = optional(object({ enabled = optional(bool), mode = optional(string), request_body_check = optional(bool), file_upload_limit_in_mb = optional(number), max_request_body_size_in_kb = optional(number) })), managed_rule_set = list(object({ type = optional(string), version = string, rule_group_override = optional(list(object({ rule_group_name = string, rule = optional(list(object({ id = number, enabled = optional(bool), action = optional(string) }))) }))) })) })` | n/a | yes |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | The name of the User Assigned Identity. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Application Gateway. |

## Example

```yaml
    values:
      # Data values
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

      # WAF
      web_application_firewall_policy:
        name: "example-waf-policy"
        policy_settings:
          enabled: true
          mode: "Detection"
          request_body_check: true
          file_upload_limit_in_mb: 100
          max_request_body_size_in_kb: 128
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
            https:
              rule_type: "Basic"

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
