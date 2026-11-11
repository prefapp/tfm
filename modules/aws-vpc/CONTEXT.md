# aws-vpc

**Not a Prefapp module.** This directory only documents the upstream community module you must use instead.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**reference directory**:
A `modules/` entry that ships documentation but no Terraform. It contains no `.tf` files and produces no resources; consuming it as a module source will fail.
_Avoid_: module, wrapper

**official module**:
[`terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) — the module to reference directly for VPCs. Prefapp does not wrap it.
