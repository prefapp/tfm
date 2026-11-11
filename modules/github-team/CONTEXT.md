# github-team

Owns one GitHub team and its membership.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**group**:
`config.group` — the team itself: name, description, privacy and optional parent team. The name `group` is the CR's vocabulary, not GitHub's.
_Avoid_: team object (ambiguous with the GitHub resource)

**parentTeamId**:
The numeric ID of the parent team, making this a child team. Null means a top-level team.

**privacy**:
`closed` (visible to the organization) or `secret`. Child teams cannot be secret.

**group member**:
A `group_members` entry. Only `username` is used; the `teamId` field is kept for input compatibility and ignored.
