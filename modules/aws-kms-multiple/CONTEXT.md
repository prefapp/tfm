# aws-kms-multiple

Fans the single-key `aws-kms` module out over a list, so one state can own several keys that share the same policy shape.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**key set**:
`kms_to_create` — the list of keys this module owns. Each entry may override `alias`, `kms_alias_prefix`, `via_service` and the read/read-write role lists; everything else is shared across the whole set.

**shared settings**:
The inputs applied identically to every key in the set: region, replica regions, account access, rotation, deletion window, multiregion and tags. A key needing different values for these belongs in its own `aws-kms` instance.

**child module**:
This module calls `aws-kms` by public Git source rather than a relative path, so a change to `aws-kms` reaches it only when the pinned reference moves.
_Avoid_: submodule, nested module
