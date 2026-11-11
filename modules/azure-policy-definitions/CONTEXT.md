# azure-policy-definitions

Owns Azure Policy definitions.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**definition**:
The rule itself — what is evaluated and what effect applies. It has no force until an *assignment* binds it to a scope, which is `azure-policy-assignments`' job.
_Avoid_: policy (ambiguous between definition and assignment)

**mode**:
Which resource types the definition is evaluated against — `All`, `Indexed`, or a provider mode. `Indexed` skips resources that cannot carry tags or locations, which is why a tag policy in `All` mode reports failures nobody can fix.

**policy_rule**:
The `if`/`then` condition and effect, passed as a **JSON string** rather than an object. Terraform cannot validate its contents, so a malformed rule fails at apply time in Azure, not at plan.
_Avoid_: policy body, rule object

**definition scope**:
`management_group_id` — where the definition is stored and therefore where it can be assigned from. A definition stored on a management group is visible to everything beneath it; one stored on a subscription is not.
