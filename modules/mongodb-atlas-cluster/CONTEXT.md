# mongodb-atlas-cluster

Owns one Atlas cluster, its backup schedule, and the restore job when the cluster is created from a snapshot or a point in time.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**replication spec**:
The node counts that make up a region's replica set: `electable` (can be voted primary), `read_only`, `analytics`. Only electable nodes affect availability; the other two are read scaling.

**restore source**:
How a new cluster is seeded: `create_cluster_from_snapshot` (from `origin_project_id` / `origin_cluster_name`) or `create_cluster_from_pitr` (to `point_in_time_utc_seconds`). Both are one-shot at creation and do nothing on later applies.
_Avoid_: backup restore (ongoing)

**cloud backup schedule**:
The retention policy Atlas applies to automatic snapshots, set by `scheduled_retention_policies` and `snapshot_execution_config`. Separate from the restore path above.

**instance size**:
`cluster_provider_instance_size_name` — the Atlas tier (M10, M30…). It fixes both CPU/RAM and the disk and feature limits.
