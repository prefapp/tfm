# Azure Application Gateway Terraform Module

## Overview

Este módulo de Terraform proporciona una solución flexible y productiva para desplegar y gestionar **Azure Application Gateway** en Azure. Permite la configuración avanzada de listeners, reglas de enrutamiento, certificados SSL, perfiles de seguridad, WAF y más, siguiendo buenas prácticas de infraestructura como código.

El módulo está diseñado para adaptarse tanto a despliegues simples como complejos, permitiendo la integración con identidades gestionadas, políticas de seguridad, certificados desde Key Vault y reglas personalizadas de firewall.

## Características principales

- Provisionamiento completo de Application Gateway: frontend, backend, listeners, reglas, certificados y WAF.
- Soporte para perfiles SSL y certificados de cliente.
- Integración con Azure Key Vault para gestión segura de certificados.
- Reglas de reescritura y enrutamiento avanzadas.
- Web Application Firewall (WAF) configurable.
- Etiquetado flexible y herencia de etiquetas del Resource Group.

## Estructura de archivos

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── data.tf
├── public_ip.tf
├── web_application_firewall_policy.tf
├── locals_*.tf
├── docs/
│   ├── header.md
│   └── footer.md
├── CHANGELOG.md
├── README.md
└── .terraform-docs.yml
```

## Ejemplo completo de uso

```yaml
values:
  tags_from_rg: true
  resource_group_name: ${{ tfworkspace:example-rg:outputs.resource_group_name }}
  user_assigned_identity: "example-identity"
  subnet:
    name: "example-subnet"
    virtual_network_name: "example-vnet"
  public_ip:
    name: "example-public-ip"
    sku: "Standard"
    allocation_method: "Static"
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
  rewrite_rule_sets:
    - name: example-rewrite
      rewrite_rules:
        - name: example-rule
          rule_sequence: 300
          conditions:
            - variable: http_request_uri
              pattern: '.*.html$'
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
            components: path_only
            reroute: false
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
