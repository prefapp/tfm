## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-repo-secrets-section/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-repo-secrets-section/_examples/basic) - Full example with Actions, Codespaces, and Dependabot secrets

## Resources

- **github_actions_public_key**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_public_key)
- **github_actions_secret**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret)
- **github_dependabot_public_key**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/dependabot_public_key)
- **github_codespaces_secret**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/codespaces_secret)
- **github_dependabot_secret**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_secret)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Import Behavior

Existing secrets can be adopted into Terraform state, but GitHub does not return secret values during import. Keep non-empty ciphertext placeholders in `config`. Without a matching `*_sha256` entry the trigger input stays `null` (stable), so the imported secret drifts from the placeholder but is never replaced.

Import addresses and IDs:

- Actions: `github_actions_secret.this["SECRET_NAME"]` with ID `repo:SECRET_NAME`.
- Codespaces: `github_codespaces_secret.this["SECRET_NAME"]` with ID `repo/SECRET_NAME`.
- Dependabot: `github_dependabot_secret.this["SECRET_NAME"]` with ID `repo:SECRET_NAME`.

The `repo` segment is the repository name inside the provider owner/organization context derived from `config.repository`.

## Delete Behavior

`terraform destroy` deletes the managed GitHub repository secrets from Actions, Codespaces, and Dependabot. This affects only the secret entries represented by `config`; deleting an imported secret permanently removes that GitHub secret value unless another system recreates it.

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
