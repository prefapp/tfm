# aws-ecs

Owns an ECS Fargate service: its task definition, execution role, optional cluster, and the load balancing and autoscaling around it.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**cluster ownership**:
Controlled by `create_cluster`. When false the service joins an existing cluster and the module does not own its lifecycle.

**ALB adoption**:
The same either/or for load balancing: `create_alb` builds a new ALB, otherwise `existing_alb_name` is looked up and the module only adds a listener rule to it.

**listener rule priority**:
`alb_listener_priority` — the slot this service takes in a shared ALB's rule list. Two services adopting the same ALB must not claim the same priority.

**static content routing**:
The `static_content_host_header` / `static_content_path_pattern` pair that sends matching requests away from the service. Both are optional and only meaningful on a shared ALB.

**scaling alarm**:
The CloudWatch alarm pair driving `aws_appautoscaling_policy` scale-up and scale-down. Configured through `ecs_autoscaling`, not by editing the alarms directly.
