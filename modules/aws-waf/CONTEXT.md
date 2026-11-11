# aws-waf

Owns a WAFv2 web ACL, the rules and match sets it uses, and its associations and logging.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**scope**:
`REGIONAL` or `CLOUDFRONT`. It fixes where the ACL can be associated and, for CloudFront, forces the whole stack into `us-east-1`.
_Avoid_: region

**rule source**:
The three places rules come from: `aws_managed_rules` (AWS rule groups), `custom_rules` (written here), and `rule_group_references` (existing groups by ARN). They share one priority space inside the ACL.

**match set**:
An `ip_sets` or `regex_pattern_sets` entry — a reusable list referenced by rules rather than inlined in them.

**association**:
An `association_resource_arns` entry binding the ACL to an ALB, API Gateway or AppSync endpoint. An ACL with no associations is inert.
