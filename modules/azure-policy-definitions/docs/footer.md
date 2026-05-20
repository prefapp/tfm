## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-definitions/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-definitions/_examples/basic) — Root module creating one custom policy definition with `jsonencode` rules (configure `azurerm` before plan — see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-policy-definitions/_examples/comprehensive) — Illustrative YAML list of policies (`values.reference.yaml`; see folder README).

## Resources

Terraform resource docs use **4.22.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.22.0`).

- **Azure Policy**: [https://learn.microsoft.com/azure/governance/policy/overview](https://learn.microsoft.com/azure/governance/policy/overview)
- **azurerm_policy_definition**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/policy_definition](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0/docs/resources/policy_definition)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.22.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
