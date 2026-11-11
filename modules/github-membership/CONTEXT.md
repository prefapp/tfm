# github-membership

Owns one user's place in a GitHub organization: their org role and their team memberships.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**user**:
The organization-level membership, whose `role` is `member` or `admin`. Optional — a config may declare only team relationships.

**relationship**:
A team membership for a username, whose `role` is `member` or `maintainer`. Note the two role vocabularies are different: org roles and team roles do not share values.
_Avoid_: team role (ambiguous — say which)

**teamId**:
Teams are referenced by numeric ID, not slug, so renaming a team does not move the membership.
