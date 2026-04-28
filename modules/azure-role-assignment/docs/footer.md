## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-role-assignment/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-role-assignment/_examples/basic) — Runnable root module with a small `role_assignments` map (scopes, `role_definition_name` / `role_definition_id`; replace IDs before plan — see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-role-assignment/_examples/comprehensive) — `module.reference.hcl` and `values.reference.yaml` mirroring the historical README samples (documentation-oriented; see folder README).

## Remote Resources

Terraform resource docs use **4.26.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`~> 4.26.0`).

- **Azure RBAC**: [https://learn.microsoft.com/azure/role-based-access-control/overview](https://learn.microsoft.com/azure/role-based-access-control/overview)
- **azurerm_role_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/role_assignment)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
