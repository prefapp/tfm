# github-repo

Owns one GitHub repository and everything scoped inside it: default branch, files, variables, labels, collaborators, team grants, Pages and branch protection.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**repository block**:
The `config.repository` object — name, visibility, topics and the merge-strategy switches. It is the only required part of the config besides `default_branch`.

**default branch**:
`config.default_branch`. `rename` decides whether an existing branch is renamed or a new default is simply pointed at.
_Avoid_: main, master

**archiveOnDestroy**:
When true, destroying the module archives the repository instead of deleting it. This changes what `terraform destroy` means for this module, so it is documented rather than assumed.

**team grant vs collaborator**:
Two different ways to grant access: `teams` binds a numeric `teamId` to a permission, `collaborators` binds a username. Teams are referenced by ID so team renames do not break the grant.

**OIDC subject claim template**:
`oidc_subject_claim_customization_template` — how this repository's Actions OIDC tokens shape their `sub` claim. `useDefault` keeps GitHub's standard format; `includeClaimKeys` replaces it.

**seeded file**:
A `config.files` entry. `overwriteOnCreate` decides whether existing content at that path may be clobbered.
