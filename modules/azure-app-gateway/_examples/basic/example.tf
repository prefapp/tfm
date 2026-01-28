// Basic example: public Application Gateway with a simple HTTP/HTTPS configuration

module "azure_app_gateway" {
  source = "../../"

  resource_group_name   = "example-rg"
  location              = "westeurope"
  user_assigned_identity = "example-identity"

  subnet = {
    name                = "example-subnet"
    virtual_network_name = "example-vnet"
  }

  public_ip = {
    name              = "example-public-ip"
    sku               = "Standard"
    allocation_method = "Static"
  }

  ssl_profiles = [
    {
      name                             = "example-ssl-profile"
      verify_client_cert_issuer_dn     = true
      verify_client_certificate_revocation = "OCSP"
      ssl_policy = {
        disabled_protocols   = ["TLSv1_0", "TLSv1_1"]
        min_protocol_version = "TLSv1_2"
        policy_name          = "AppGwSslPolicy20170401S"
        cipher_suites = [
          "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
          "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
        ]
      }
      ca_certs_origin = {
        github_owner      = "gh-owner"
        github_repository = "gh-repo"
        github_branch     = "gh-branch"
        github_directory  = "gh-dir"
      }
    }
  ]

  rewrite_rule_sets = [
    {
      name = "example-rewrite"
      rewrite_rules = [
        {
          name          = "example-rule"
          rule_sequence = 300
          conditions = [
            {
              variable    = "http_request_uri"
              pattern     = ".*.html$"
              ignore_case = true
              negate      = false
            },
            {
              variable    = "http_request_method"
              pattern     = "^POST$"
              ignore_case = true
              negate      = true
            }
          ]
          request_header_configurations = [
            {
              header_name  = "X-Rewrite-Rule"
              header_value = "applied"
            }
          ]
          response_header_configurations = [
            {
              header_name  = "X-Cache-Control"
              header_value = "max-age=3600"
            },
            {
              header_name  = "X-Server"
              header_value = "custom-app"
            }
          ]
          url_rewrite = {
            source_path = "^/api/v1/(.*)"
            components  = "path_only"
            reroute     = false
          }
        }
      ]
    }
  ]

  web_application_firewall_policy = {
    name = "example-waf-policy"
    policy_settings = {
      enabled                     = true
      mode                        = "Detection"
      request_body_check          = true
      file_upload_limit_in_mb     = 100
      max_request_body_size_in_kb = 128
    }
    custom_rules = [
      {
        name     = "HeaderName"
        enabled  = true
        priority = 1
        rule_type = "MatchRule"
        action    = "Allow"
        match_conditions = [
          {
            match_values = ["example.com"]
            operator     = "Equal"
            match_variables = [
              {
                variable_name = "RequestHeaders"
                selector      = "Host"
              }
            ]
          }
        ]
      },
      {
        name     = "BlockUserAgentWindows"
        enabled  = true
        priority = 2
        rule_type = "MatchRule"
        action    = "Block"
        match_conditions = [
          {
            operator           = "Contains"
            negation_condition = false
            match_values       = ["Windows"]
            match_variables = [
              {
                variable_name = "RequestHeaders"
                selector      = "UserAgent"
              }
            ]
          }
        ]
      }
    ]
    managed_rule_set = [
      {
        type    = "OWASP"
        version = "3.2"
        rule_group_override = [
          {
            rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
            rule = [
              {
                id      = 932100
                action  = "AnomalyScoring"
                enabled = false
              },
              {
                id      = 932110
                action  = "AnomalyScoring"
                enabled = false
              }
            ]
          }
        ]
      }
    ]
  }

  application_gateway = {
    name = "example-appgw"
    identity = {
      type = "UserAssigned"
    }
    enable_http2 = true
    sku = {
      name     = "WAF_v2"
      tier     = "WAF_v2"
      capacity = 0
    }
    gateway_ip_configuration = {
      name = "appGatewayIpConfig"
    }
    autoscale_configuration = {
      min_capacity = 0
      max_capacity = 10
    }
    frontend_ports = [
      {
        name = "port_80"
        port = 80
      },
      {
        name = "port_443"
        port = 443
      }
    ]
    frontend_ip_configuration = {
      name                         = "appGwPublicFrontendIpIPv4"
      private_ip_address_allocation = "Dynamic"
    }
    ssl_certificates = [
      {
        name               = "example-cert-1"
        key_vault_secret_id = "https://example-kv.vault.azure.net/secrets/example-cert-1"
      }
    ]
  }

  tags = {
    environment = "dev"
  }
}

