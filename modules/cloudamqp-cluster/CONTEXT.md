# cloudamqp-cluster

Owns a CloudAMQP instance and everything attached to it: firewall, alarms, notification recipients, and metric and log integrations.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**instance**:
The `cloudamqp_instance` — the managed RabbitMQ or LavinMQ cluster itself, including its plan and region.

**alarm and recipient**:
An alarm watches a metric; a *recipient* (`cloudamqp_notification`) is where it is sent. An alarm with no recipient fires into nothing.

**integration**:
An outbound feed of metrics (`metrics_integrations`) or logs (`logs_integrations`) to an external observability platform. Each integration is provider-specific and independent.

**firewall rule set**:
`firewall_rules`, applied only when `enable_firewall` is true. CloudAMQP replaces the whole rule set on change, so the list is the complete allowed surface, not an addition to it.
_Avoid_: security group

**vpc_connect**:
The optional PrivateLink/Private Service Connect attachment. It can be declared here or in `cloudamqp-vpc`; owning it in two states at once is what breaks.
