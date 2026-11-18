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
A principal allowed past the rules, identified by `actor_type` plus one reference: `actor_id` (numeric), `actor_slug` (team or GitHub App slug, resolved inside Terraform) or `actor_role` (`maintain`, `write` or `admin` for `RepositoryRole`). `bypass_mode` decides whether the exemption is always in force or only for pull requests.

**condition**:
The `ref_name` / `repository_name` / `repository_property` include and exclude lists that select what the ruleset covers. Exactly one repository target applies, `repository_name` or `repository_property`. An empty include list matches nothing.

**repository property**:
A custom or system repository property — a `name` plus the `property_values` to match — used to target repositories instead of a name pattern. `source` is `custom` or `system`.

**rule**:
One entry of `rules`, in the GitHub API's `{type, parameters}` array shape. Boolean rules (`creation`, `deletion`, `update`, `non_fast_forward`, `required_linear_history`, `required_signatures`) carry no parameters.

**export field**:
`id`, `source_type` and `source` — present in a GitHub API export and accepted so exports can be pasted in unmodified, but ignored by the module.
_Avoid_: unsupported field
