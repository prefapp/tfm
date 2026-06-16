# Specification: Add `hasDiscussions` option to github-repo module

**Epic:** prefapp/gitops-k8s#2133 — Add support for GitHub Discussions  
**Issue:** prefapp/gitops-k8s#2186 — `[gh-provisioner]` Add support for discussions in gh-repo tfm  
**Module:** `modules/github-repo`

---

> **Context:** This spec covers the `github-repo` module portion of the GitHub
> Discussions epic. The gh_provisioner in `prefapp/gitops-k8s` already sends
> `hasDiscussions` in the `config.repository` object. This module must accept it
> and pass it to the `github_repository` resource.

---

## Problem

The `github-repo` module currently supports `hasIssues` and `hasWiki` as boolean
toggles on the `github_repository` resource, but does **not** support
`has_discussions`. The `gh_provisioner` entity in `prefapp/gitops-k8s` already
includes `hasDiscussions` in the Terraform config it generates (`config.repository`).
However, because the module's `variables.tf` does not declare a `hasDiscussions`
field, the value is silently ignored by Terraform.

This means users cannot enable or disable GitHub Discussions through Firestartr
even though every other layer of the stack is wired to support it.

## Goal

Add `hasDiscussions` optional boolean field to `config.repository` so the
module accepts and applies the discussion toggle from the generated
`terraform.tfvars.json`.

## Input Shape

```yaml
repository:
  name: my-repo
  hasDiscussions: true
```

## Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `hasDiscussions` | `bool` | `true` | Enable GitHub Discussions on the repository (matches GitHub API default) |

## Scope

- Add `hasDiscussions` to `variables.tf` inside the `config.repository` object as
  an optional boolean (default `true`)
- Add `has_discussions` attribute to `github_repository.this` in `main.tf`
- Update `docs/header.md` to mention Discussions in the key features list
- Regenerate `README.md` with `terraform-docs .`

## Out of Scope

- Changes to other modules
- Adding `hasProjects` or `hasDownloads` (separate issue if desired)
- Modifying any existing behavior of `hasIssues`, `hasWiki`, or other fields
- Changes in `prefapp/gitops-k8s` (handled by the epic's other sub-issues)

## Acceptance Criteria

- `hasDiscussions` is an optional boolean in `config.repository` (default `true`)
- `github_repository.this` resource sets `has_discussions` from the config
- Module passes `terraform fmt` and `terraform validate`
- Documentation is updated and README regenerated
- `tasks.md` is complete and included in the PR

## Import Behavior

`has_discussions` is a property of `github_repository.this`. No new resources are
introduced. Import behavior is unchanged — users import the repository via
`terraform import github_repository.this <repo_id>`.

## Delete Behavior

No change. `terraform destroy` removes the repository as before. The new boolean
attribute is part of the repository resource and follows the same lifecycle.

## References

- Epic: prefapp/gitops-k8s#2133
- Sub-issue: prefapp/gitops-k8s#2186
- Existing spec for `hasWiki` (same pattern): `specs/github-repo/003-add-discussion-wiki-options/`
- Terraform provider: `github_repository` resource `has_discussions` attribute (available since provider ~5.42)
