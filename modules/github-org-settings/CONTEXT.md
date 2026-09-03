# github-org-settings

Owns the organization-wide settings document.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**billing email**:
The one required field. Everything else in the settings object is optional and falls back to a module default, not to the organization's current value.

**member capability**:
The `membersCan*` family — what non-admin members may create (repositories by visibility, Pages, forks of private repositories).

**new-repository security default**:
The `*EnabledForNewRepositories` family (advanced security, Dependabot alerts and updates, dependency graph, secret scanning and push protection). These apply to repositories created **after** the setting, and do not retrofit existing ones.
_Avoid_: org security setting (ambiguous)

**singleton**:
There is one settings resource per organization, so exactly one instance of this module may own it.
