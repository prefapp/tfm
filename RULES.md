# gh-provisioner Compatible Module Rules

These rules apply to Terraform modules intended to be consumed by Firestartr `gh_provisioner` from `prefapp/gitops-k8s`.

## 1. Compatibility Contract

A compatible module must be fed by one generated `terraform.tfvars.json` document with exactly one root configuration key:

```json
{
  "config": {}
}
```

The module must define one top-level Terraform variable:

```hcl
variable "config" {
  description = "..."
  type        = object({})
}
```

The module may define other operational variables only when they are not part of Firestartr CR desired state and there is a documented reason. Prefer not to add them.

## 2. State Ownership

One `gh_provisioner`-compatible module maps to:

- One Firestartr Kubernetes custom resource.
- One `gh_provisioner` entity.
- One Terraform state.
- One generated `terraform.tfvars.json` document.

If several Terraform resources are needed to represent one Firestartr resource, compose them inside one module.

If several independently managed artifacts are needed, use a composite module pattern. Existing examples include `github-files-set` and `github-org-rulesets`.

## 3. Input Shape

The `config` object must be explicit and typed.

Required practices:

- Use `object(...)`, `map(object(...))`, or `list(object(...))` with concrete attribute types.
- Use `optional(...)` defaults where Terraform should own a default.
- Add `validation` blocks for enum values, uniqueness, non-empty strings, and provider constraints.
- Use naming that matches the Firestartr CR or established module convention.
- Keep generated JSON friendly. Avoid requiring HCL-only constructs from the caller.

Do not accept broad `any` unless the provider schema is genuinely unbounded and the reason is documented.

## 4. Resource Addresses And Imports

Every compatible module must document Terraform resource addresses that `gh_provisioner` may need for import.

For each importable resource, document:

- Terraform address, for example `github_repository.this`.
- Provider import ID format.
- How Firestartr can discover that ID, for example from a GitHub API lookup.
- Whether import is mandatory for adopting existing resources.

If the Terraform provider does not support import, document that explicitly.

## 5. Delete Semantics

Every compatible module must document delete behavior.

Safe delete means `terraform destroy` removes only the resource represented by the Firestartr CR.

Unsafe delete includes behavior that resets settings, mutates a broader resource, archives instead of deletes, or affects unrelated objects. If delete is unsafe, the module documentation and `gitops-k8s` integration must choose a non-destructive strategy, such as state-only unmanagement, and tests must cover the decision.

## 6. Outputs

Outputs must be stable and useful for Firestartr.

Include outputs for:

- Provider IDs needed by dependent resources.
- Names, slugs, node IDs, or URLs used by other Firestartr CRs.
- Values that help tests and reconciliation verify what was created.

Do not output secrets unless required, and mark them `sensitive = true`.

## 7. Documentation And Examples

Follow `CONTRIBUTING.md` for all modules.

Additionally, compatible modules should include in `docs/header.md` or `docs/footer.md`:

- A note that the module is `gh_provisioner` compatible.
- The expected `config` structure.
- A minimal example using `config`.
- Import behavior.
- Delete behavior.
- Any Firestartr-specific lifecycle notes.

The generated `README.md` must be updated with `terraform-docs .` after input, output, or docs changes.

## 8. Testing

Compatible modules must be testable without Firestartr.

At minimum, provide examples that can run:

- `terraform init`
- `terraform validate`
- `terraform plan` when provider credentials and required IDs are available

When the repository supports Terraform tests, add tests that cover valid input, invalid input validations, and important lifecycle behavior.

## 9. Firestartr Integration Checklist

Before marking a module ready for `gh_provisioner`, confirm:

- `variables.tf` exposes `variable "config"`.
- `main.tf` consumes `var.config`.
- `outputs.tf` exposes stable outputs.
- `versions.tf` declares provider requirements.
- Examples use the `config` object.
- Docs explain import and delete behavior.
- The module can be referenced by `gitops-k8s` using a release tag.
- A matching `gh_provisioner` entity can map a CR spec to this `config` shape without special Terraform logic.

If any item is missing, document the gap before opening or updating the Firestartr integration PR.
