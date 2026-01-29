module "azure_policy_definitions" {
  source = "../../"

  policies = [
    {
      name         = "example-policy"
      policy_type  = "Custom"
      mode         = "All"
      display_name = "Example Policy"
      description  = "A sample policy to audit location."
      policy_rule = jsonencode({
        "if" = {
          "field"  = "location"
          "equals" = "westeurope"
        }
        "then" = {
          "effect" = "audit"
        }
      })
      metadata   = "{}"
      parameters = "{}"
    }
  ]
}

