## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-customrole/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-customrole/_examples/basic) — Runnable minimal example: one custom role at subscription scope (see the folder README for `terraform plan` / `apply` notes).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-customrole/_examples/comprehensive) — Documentation-only reference with `values.reference.yaml` for assignable scopes and permissions.

## Resources

Doc links match the `azurerm` constraint in `versions.tf` (~> 4.16.0); resource docs use **4.16.0** as the baseline.

- **azurerm_role_definition**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_definition](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_definition)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
