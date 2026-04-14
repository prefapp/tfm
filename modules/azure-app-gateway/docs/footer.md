## Examples

- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-app-gateway/_examples/comprehensive) — Large **`values.reference.yaml`** migrated from the legacy README (Prefapp-style `values:` root); adapt placeholders for your tenant.
- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-app-gateway/_examples/basic) — Pointers and prerequisites only (this module is driven by rich input objects rather than a tiny HCL snippet).

## Operational notes

- **`external` data sources** run `bash` with `wget` and `jq` against **api.github.com** when `ssl_profiles` pulls CA material. Ensure the Terraform runtime has those tools and network egress, or keep `ssl_profiles` empty if you do not need that path.

## Remote resources

- **Application Gateway**: [https://learn.microsoft.com/azure/application-gateway/overview](https://learn.microsoft.com/azure/application-gateway/overview)
- **WAF policy**: [https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-waf-overview](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-waf-overview)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
