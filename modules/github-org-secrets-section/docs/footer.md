## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/github-org-secrets-section/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/github-org-secrets-section/_examples/basic) - Full example with Actions, Codespaces, and Dependabot secrets

## Resources

- **github_actions_organization_public_key**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/actions_organization_public_key)
- **github_actions_organization_secret**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_secret)
- **github_actions_organization_secret_repositories**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_secret_repositories)
- **github_codespaces_organization_secret**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/codespaces_organization_secret)
- **github_dependabot_organization_public_key**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/dependabot_organization_public_key)
- **github_dependabot_organization_secret**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_organization_secret)
- **github_dependabot_organization_secret_repositories**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_organization_secret_repositories)
- **GitHub Terraform Provider**: [Official Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Import Behavior

Existing secrets can be adopted into Terraform state, but GitHub does not return secret values during import. Keep non-empty ciphertext placeholders in `config`. Without a matching `*_sha256` entry the trigger input stays `null` (stable), so the imported secret drifts from the placeholder but is never replaced.

Import addresses and IDs:

- Actions: `github_actions_organization_secret.this["SECRET_NAME"]` with ID `SECRET_NAME`.
- Codespaces: `github_codespaces_organization_secret.this["SECRET_NAME"]` with ID `SECRET_NAME`.
- Dependabot: `github_dependabot_organization_secret.this["SECRET_NAME"]` with ID `SECRET_NAME`.
- Actions repos binding: `github_actions_organization_secret_repositories.this["SECRET_NAME"]` with ID `SECRET_NAME`.
- Dependabot repos binding: `github_dependabot_organization_secret_repositories.this["SECRET_NAME"]` with ID `SECRET_NAME`.

## Delete Behavior

`terraform destroy` deletes the managed GitHub organization secrets from Actions, Codespaces, and Dependabot, and removes the selected repository bindings. This affects only the secret entries represented by `config`; deleting an imported secret permanently removes that GitHub secret value unless another system recreates it.

Deleting a secret also deletes its associated repository bindings (if any). The selected repository access is revoked when the binding resource is destroyed.

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
