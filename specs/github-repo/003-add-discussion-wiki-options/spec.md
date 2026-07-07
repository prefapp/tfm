# Specification: Add `hasWiki` option to github-repo module

**Issue:** [#1295](https://github.com/prefapp/tfm/issues/1295)
**Module:** `modules/github-repo`

## Problem

The `github-repo` module currently supports `hasIssues` for the `github_repository` resource, but does **not** support the `has_wiki` repository feature. Users who need to enable the wiki on repositories managed by this module must do so outside of Terraform or maintain separate resources.

The config exported by `gh_provisioner` includes this option, and the module must align with that shape.

## Goal

Add `hasWiki` optional boolean field to the `config.repository` object so users can enable GitHub Wiki directly through the module.

## Input Shape

```yaml
repository:
  name: my-repo
  hasWiki: true
```

## Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `hasWiki` | `bool` | `true` | Enable GitHub Wiki on the repository (matches GitHub API default) |

## Scope

- Add `hasWiki` to `variables.tf` inside the `config.repository` object as an optional boolean (default `true`)
- Add `has_wiki` attribute to `github_repository` in `main.tf`
- Update `docs/header.md` with a mention of the new option
- Regenerate `README.md` with `terraform-docs .`

## Out of Scope

- Changes to other modules
- Adding `hasDiscussions` or `hasProjects` (not requested in this issue)
- Modifying any existing behavior of `hasIssues`

## Acceptance Criteria

- `hasWiki` is an optional boolean in `config.repository` (default `true`)
- `github_repository.this` resource sets `has_wiki` from the config
- Module passes `terraform fmt` and `terraform validate`
- Documentation is updated and README regenerated
- `tasks.md` is complete and included in the PR

## Import Behavior

These attributes are properties of `github_repository.this`. No new resources are introduced, so import behavior is unchanged — users import the repository via `terraform import github_repository.this <repo_id>`.

## Delete Behavior

No change. `terraform destroy` removes the repository as before. The new boolean attribute is part of the repository resource and follows the same lifecycle.
