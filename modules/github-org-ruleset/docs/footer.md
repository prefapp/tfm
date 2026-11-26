## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples/basic) - Org-wide default branch protection targeting repositories by name, with a CI status check and a numeric bypass actor (`config.json`)
- [advanced](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples/advanced) - Full GitHub API export format targeting repositories by custom property, with required_reviewers, copilot_code_review, and extra fields that are silently ignored (`config.json`)
- [bypass-actors](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples/bypass-actors) - Bypass actors referenced by team slug, app slug, and repository role instead of numeric IDs (`config.json`)
- [push-ruleset](https://github.com/prefapp/tfm/tree/main/modules/github-org-ruleset/_examples/push-ruleset) - Push ruleset targeting repositories by custom property, with file extension and file size rules (`config.json`)

## Resources

- **github_organization_ruleset**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/6.11.1/docs/resources/organization_ruleset)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)
- **GitHub Organization Rulesets**: [GitHub Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
