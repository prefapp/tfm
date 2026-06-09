# Specification: Add `hasDiscussions` and `hasWiki` options to github-repo module

**Issue:** [#1295](https://github.com/prefapp/tfm/issues/1295)
**Module:** `modules/github-repo`

## Problem

The `github-repo` module currently supports `hasIssues` for the `github_repository` resource, but does **not** support the `has_discussions` or `has_wiki` repository features. Users who need to enable discussions or wiki on repositories managed by this module must do so outside of Terraform or maintain separate resources.

The config exported by `gh_provisioner` includes these options, and the module must align with that shape.

## Goal

Add `hasDiscussions` and `hasWiki` optional boolean fields to the `config.repository` object so users can enable GitHub Discussions and GitHub Wiki directly through the module.

## Input Shape

```yaml
repository:
  name: my-repo
  hasDiscussions: true
  hasWiki: true
```

## Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `hasDiscussions` | `bool` | `false` | Enable GitHub Discussions on the repository (provider default: `false`) |
| `hasWiki` | `bool` | `false` | Enable GitHub Wiki on the repository |

Both fields default to `false` for safety — users must explicitly opt-in to enable discussions or wiki on the repository.

## Scope

- Add `hasDiscussions` and `hasWiki` to `variables.tf` inside the `config.repository` object as optional booleans (default `false`)
- Add `has_discussions` and `has_wiki` attributes to `github_repository` in `main.tf`
- Update `docs/header.md` with a mention of the new options
- Regenerate `README.md` with `terraform-docs .`

## Out of Scope

- Changes to other modules
- Adding `hasProjects` (not requested in this issue)
- Modifying any existing behavior of `hasIssues`

## Acceptance Criteria

- `hasDiscussions` and `hasWiki` are optional booleans in `config.repository` (default `false`)
- `github_repository.this` resource sets `has_discussions` and `has_wiki` from the config
- Module passes `terraform fmt` and `terraform validate`
- Documentation is updated and README regenerated
- `tasks.md` is complete and included in the PR

## Import Behavior

These attributes are properties of `github_repository.this`. No new resources are introduced, so import behavior is unchanged — users import the repository via `terraform import github_repository.this <repo_id>`.

## Delete Behavior

No change. `terraform destroy` removes the repository as before. The new boolean attributes are part of the repository resource and follow the same lifecycle.
