# tftest.hcl

variables {
  policies = [
    {
      name         = "test-policy"
      policy_type  = "Custom"
      mode         = "All"
      display_name = "Test Policy"
      description  = "A custom policy for testing"
      policy_rule  = "{\"if\": {\"field\": \"type\", \"equals\": \"Microsoft.Compute/virtualMachines\"}}"
    }
  ]
}

run "create_policy_definition" {
  command = "plan"

  assert {
    condition     = azurerm_policy_definition.this["test-policy"].name == "test-policy"
    error_message = "Policy definition name did not match expected"
  }

  assert {
    condition     = azurerm_policy_definition.this["test-policy"].policy_type == "Custom"
    error_message = "Policy type did not match expected"
  }

  assert {
    condition     = azurerm_policy_definition.this["test-policy"].mode == "All"
    error_message = "Policy mode did not match expected"
  }
}
