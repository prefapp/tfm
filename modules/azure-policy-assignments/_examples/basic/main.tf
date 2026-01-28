module "azure_policy_assignments" {
  source = "../../"

  assignments = [
    {
      name        = "example-assignment-subscription"
      policy_type = "builtin"
      policy_name = "Allowed locations"
      scope       = "subscription"
    },
    {
      name        = "example-assignment-rg"
      policy_type = "builtin"
      policy_name = "Allowed virtual machine size SKUs"
      resource_group_name = "test"
      scope       = "resource group"
    }
  ]
}

