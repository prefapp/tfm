# Specification: Remove deprecated `pages` block from github-repo module

**Issue:** [#1255](https://github.com/prefapp/tfm/issues/1255)  
**Module:** `modules/github-repo`

### Problem
The `pages` block inside the `github_repository` resource has been **deprecated** by the `terraform-provider-github`: https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_pages.  
Continuing to use it will eventually break the module when the provider removes support.

### Goal
Migrate the `pages` configuration from the embedded `pages { ... }` block inside `github_repository` to the dedicated `github_repository_pages` resource (the new official way).

### Scope
- Update `variables.tf` (remove or deprecate the `pages` variable)
- Update `main.tf` (remove `pages` block from `github_repository`, add `github_repository_pages` resource)
- Update `outputs.tf` (adjust any outputs that exposed pages settings)
- Maintain backward compatibility where possible (or clearly document the breaking change)
- Update module documentation and examples
- Keep all existing tests passing

### Out of scope
- Changes to other modules
- Major refactoring unrelated to pages

### Acceptance Criteria
- No more `pages` block inside `github_repository`
- Pages functionality fully working via `github_repository_pages`
- Module still passes all existing tests
- `tasks.md` is updated and included in the PR
- `CONSTITUTION.md` / `AGENTS.md` / `CONTRIBUTING.md` rules are followed
