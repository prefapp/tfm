# Tasks: Add `hasDiscussions` option to github-repo module

**Module:** github-repo
**Spec:** spec.md
**Plan:** plan.md

---

## Tasks

- [x] 1. Update `variables.tf` — add optional `hasDiscussions` field to `config.repository` (default `true`)
- [x] 2. Update `main.tf` — add `has_discussions` attribute to `github_repository.this`
- [x] 3. Update `docs/header.md` — mention Discussions in key features list
- [x] 4. Regenerate `README.md` with `terraform-docs .`
- [x] 5. Run `terraform fmt` and `terraform validate`
- [ ] 6. Final review and create PR

**Status:** Implementation complete — pending PR creation

---

## Validation Commands

```sh
cd modules/github-repo

# Format
terraform fmt

# Validate
terraform init && terraform validate

# Regenerate docs
terraform-docs .
# or: go run github.com/terraform-docs/terraform-docs@latest .
```

---

## Commit Message

```
feat(github-repo): add hasDiscussions support

Add optional `hasDiscussions` boolean to config.repository (default true)
so the module accepts and applies the GitHub Discussions toggle from
generated terraform.tfvars.json.

This is part of the GitHub Discussions epic (prefapp/gitops-k8s#2133)
and unblocks the gh-provisioner integration (prefapp/gitops-k8s#2186).
```

---

## PR Description

```
## What

Adds `hasDiscussions` optional boolean to the github-repo module.

## Why

The gh_provisioner in gitops-k8s already generates
`config.repository.hasDiscussions` in its Terraform document, but the
module silently ignores it because the variable was not declared.

## Changes

- variables.tf: add `hasDiscussions = optional(bool, true)` to config.repository
- main.tf: add `has_discussions = var.config.repository.hasDiscussions`
- docs/header.md: mention discussions in key features
- README.md: regenerated with terraform-docs

Part of epic prefapp/gitops-k8s#2133
Closes prefapp/gitops-k8s#2186
```
