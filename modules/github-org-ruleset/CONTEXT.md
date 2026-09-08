# github-org-ruleset

Owns one GitHub organization ruleset.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**target**:
What the ruleset applies to: `branch`, `tag` or `push`.

**enforcement**:
`disabled`, `evaluate` or `active`. `evaluate` reports what would have been blocked without blocking it — a dry-run mode, not an off switch.

**bypass actor**:
A principal allowed past the rules, identified by `actor_type` and `actor_id`, with `bypass_mode` deciding whether the exemption is always in force or only for pull requests.

**condition**:
The `ref_name` / `repository_name` include and exclude lists that select what the ruleset covers. An empty include list matches nothing.

**rule**:
One entry of `rules`, in the GitHub API's `{type, parameters}` array shape. Boolean rules (`creation`, `deletion`, `update`, `non_fast_forward`, `required_linear_history`, `required_signatures`) carry no parameters.

**export field**:
`id`, `source_type` and `source` — present in a GitHub API export and accepted so exports can be pasted in unmodified, but ignored by the module.
_Avoid_: unsupported field
