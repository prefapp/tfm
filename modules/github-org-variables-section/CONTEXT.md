# github-org-variables-section

Owns one *section* of an organization's GitHub Actions variables — not necessarily all of them.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**section**:
The subset of organization variables this module instance owns. Several sections can coexist in one organization, each in its own state, provided their variable names do not overlap.
_Avoid_: all variables, the variable set

**visibility**:
`all`, `private` or `selected` — which repositories can read the variable.

**selectedRepositoryIds**:
The `owner/repo` list a variable is scoped to. It is read only when visibility is `selected` and silently ignored otherwise.
