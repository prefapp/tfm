# azure-cognitive-account

Owns one Azure Cognitive Services account, including Azure OpenAI accounts.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**Cognitive Services account**:
The Azure resource represented by `azurerm_cognitive_account`. For Azure OpenAI, its
`endpoint` is the base URL clients use with a deployed model.

**network ACLs**:
The account-level public network rules: a default allow/deny action, optional IP
rules, optional subnet rules, and an optional trusted Azure services bypass.

**tag inheritance**:
When `tags_from_rg` is enabled, resource group tags are merged with module tags;
module-supplied values win when a key exists in both maps.
