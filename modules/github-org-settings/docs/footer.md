## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-org-settings/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-org-settings/_examples/basic) - Minimal organization settings managed through a `config.json` file.

## Import Behavior

This module manages one Terraform resource:

- Terraform address: `github_organization_settings.this`
- Import ID: GitHub organization numeric ID

The organization ID can be discovered with the GitHub REST API `GET /orgs/{org}`. Firestartr `gh_provisioner` should import using that numeric ID when adopting existing organization settings.

## Delete Behavior

`github_organization_settings` does not delete the GitHub organization. Terraform provider delete semantics reset organization settings to provider defaults. This is unsafe for normal Firestartr deletion because deleting the CR could unexpectedly mutate organization-wide settings.

Firestartr integrations should treat deletion of the corresponding CR as non-destructive unmanagement, for example by removing Terraform state only instead of running `terraform destroy`.

## Resources

- **github_organization_settings**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings)
- **GitHub REST API - Get an organization**: [Official Documentation](https://docs.github.com/en/rest/orgs/orgs#get-an-organization)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
