# cloudamqp-vpc

Owns a standalone CloudAMQP VPC and, optionally, its VPC Connect attachment.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**standalone VPC**:
A VPC created independently of any instance, so several instances can later join it. The alternative — a VPC created inline with one instance — is not what this module does.

**vpc_connect**:
The optional PrivateLink / Private Service Connect endpoint service on the VPC. It is optional precisely because a VPC is useful without it, and because `cloudamqp-cluster` can own it instead. Exactly one module instance must own a given attachment.
