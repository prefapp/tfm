## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azuread-group/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azuread-group/_examples/basic) — Minimal module call with empty role lists (adjust for your tenant).
- [with_yaml_file](https://github.com/prefapp/tfm/tree/main/modules/azuread-group/_examples/with_yaml_file) — Load `members`, `owners`, and roles from `values.yaml`.

## Remote resources

- **Microsoft Entra ID (Azure AD) groups**: [https://learn.microsoft.com/entra/identity/](https://learn.microsoft.com/entra/identity/)
- **Terraform AzureAD provider**: [https://registry.terraform.io/providers/hashicorp/azuread/latest](https://registry.terraform.io/providers/hashicorp/azuread/latest)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Known issues

1. Sometimes, if you try to remove a `azuread_privileged_access_group_eligibility_schedule` resource, the provider crashes; see [terraform-provider-azuread#1399](https://github.com/hashicorp/terraform-provider-azuread/issues/1399).
2. If you want to update a `azuread_privileged_access_group_eligibility_schedule`, the provider may show a misleading error. You may need to remove the resource from Terraform state and recreate it, which can conflict with the previous point; see [terraform-provider-azuread#1412](https://github.com/hashicorp/terraform-provider-azuread/issues/1412).

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
