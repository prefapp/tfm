# Implementation Plan: Remove deprecated pages section

**Reference:** spec.md + issue #1255

### High-level steps
1. Analyze current implementation of `pages` in the module
2. Map old `pages` block variables to the new `github_repository_pages` resource
3. Refactor `main.tf`
4. Update `variables.tf` (deprecate old variable or remove it)
5. Update `outputs.tf`
6. Update README.md and any examples
7. Run tests and validate

### Technical notes
- New resource: `github_repository_pages`
- Old block was nested inside `github_repository`
- Need to handle `source` / `build` / `cname` etc. that were previously in the pages block
