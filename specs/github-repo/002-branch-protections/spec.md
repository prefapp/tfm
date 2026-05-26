# Specification: Add support for legacy branch protections in github-repo module

**Issue:** [github-repository Add support for legacy branch protections](https://github.com/prefapp/tfm/issues/1273)
**Module:** `modules/github-repo`

## Problem

The `github-repo` module does not currently support managing legacy branch protections (`github_branch_protection` resource). Users must manage branch protections outside of this module or use rulesets via a separate module.

Following the related JSON Schema in the Firestartr/gitops-k8s ecosystem, we need to add support for a new input var `branchProtections`, with an array of protections.

## Goal

Add a `branchProtections` optional field to the `config` variable that allows users to define legacy branch protection rules per branch pattern.

## Input Shape

```yaml
branchProtections:
  - branch: master
    statusChecks: []
    requiredReviewersCount: 1
    requiredCodeownersReviewers: false
    enforceAdmins: false
    requireSignedCommits: false
    requireConversationResolution: false
```

## Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `branch` | `string` | required | Branch pattern (e.g. `main`, `master`, `release/*`) |
| `statusChecks` | `list(string)` | `[]` | Required status check contexts |
| `requiredReviewersCount` | `number` | `0` | Number of required approving reviewers |
| `requiredCodeownersReviewers` | `bool` | `false` | Require code owner review |
| `enforceAdmins` | `bool` | `false` | Enforce protections for admins |
| `requireSignedCommits` | `bool` | `false` | Require signed commits |
| `requireConversationResolution` | `bool` | `false` | Require all conversations to be resolved before merging |

## Scope

- Add `branchProtections` to `variables.tf` as an optional list
- Add `github_branch_protection` resource in `main.tf`
- Add `branch_protections` output in `outputs.tf`
- Update `docs/header.md` and `docs/footer.md` with examples
- Regenerate `README.md`

## Out of Scope

- Changes to other modules
- Rulesets (handled by separate `github-org-rulesets` / `github-org-ruleset` modules)

## Acceptance Criteria

- `branchProtections` is an optional list (defaults to `[]`) in the `config` variable
- `github_branch_protection` resources are created for each entry, keyed by branch pattern
- Module passes `terraform validate` and `terraform fmt`
- Documentation is updated and README regenerated
- `tasks.md` is complete and included in the PR
