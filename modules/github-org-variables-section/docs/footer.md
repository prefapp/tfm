## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-org-variables-section/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-org-variables-section/_examples/basic) - Full example covering all three visibility modes through a `config.json` file.

## Resources

- **github_actions_organization_variable**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable)
- **github_repository** (data source): [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Import Behavior

This module manages `github_actions_organization_variable` resources via `for_each` over the `variables` map.

- Terraform address: `github_actions_organization_variable.this["VARIABLE_NAME"]`
- Import ID: the variable name (e.g. `MY_VARIABLE`)

The variable name can be discovered from the GitHub REST API or the GitHub Actions organization variables UI. Firestartr `gh_provisioner` should import using the variable name when adopting existing organization variables.

## Delete Behavior

`terraform destroy` deletes the managed organization variables from GitHub Actions. This affects only the variable entries defined in `config.variables`. Removing a single variable from the config safely destroys only that variable; other variables and broader organization settings are unaffected.

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
