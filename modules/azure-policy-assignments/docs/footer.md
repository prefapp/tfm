## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples/basic) — One subscription-scoped assignment using a built-in policy display name (configure `azurerm` and validate the policy exists — see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-assignments/_examples/comprehensive) — Illustrative `assignments` across several scopes (`values.reference.yaml`; replace IDs — see folder README).

## Resources

Terraform resource docs use **4.22.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.22.0`).

- **Azure Policy — assignment structure**: [https://learn.microsoft.com/azure/governance/policy/concepts/assignment-structure](https://learn.microsoft.com/azure/governance/policy/concepts/assignment-structure)
- **azurerm_subscription_policy_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/subscription_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/subscription_policy_assignment)
- **azurerm_resource_group_policy_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_group_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_group_policy_assignment)
- **azurerm_resource_policy_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/resource_policy_assignment)
- **azurerm_management_group_policy_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/management_group_policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/management_group_policy_assignment)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
