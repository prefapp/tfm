# github-org-rulesets

Composite module: owns several organization rulesets in one state, by fanning `github-org-ruleset` out over a map.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**ruleset map**:
`config` is a map of ruleset key to ruleset object. Each entry has exactly the shape `github-org-ruleset` accepts, so the two modules stay interchangeable.

**composite module**:
This module declares no resources of its own; it exists so one CR can own several rulesets inside one Terraform state. It calls the single-ruleset module by relative path, so the two always move together.

**unmodeled parameter**:
Any rule parameter key this module's type does not declare. Callers must strip them before passing input — Terraform rejects unknown object attributes rather than ignoring them.
