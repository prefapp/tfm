# aws-parameter-store

Owns SSM parameters for an environment plus one IRSA role per service that reads them.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**service**:
An entry of `services`. Each one gets an IAM role trusted by the EKS service account `<name>-<env>-sa` in namespace `<env>`, attached to the shared read policy. The naming convention is fixed by the module, not configurable.

**seeded parameter**:
A parameter created with the placeholder value `TODO: Replace with a secret`. The module owns the parameter's existence and type; the real value is written out of band and ignored on later plans.
_Avoid_: secret, managed value
