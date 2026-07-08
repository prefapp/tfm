# Region prefix and `origin-region` tag encode the source region

In `aws-secretsmanager-replication`, when `add_region_prefix_to_name = true`, a replicated secret's name is prefixed with the **source** region (`<source-region>-<secret-name>`), and the `origin-region` replication tag stores the **source** region — not the destination region where the replica lives.

This is deliberate and counter to the intuitive reading (a replica sits in the destination region, so a naive implementation prefixes with the destination). We prefix with the source for disaster-recovery traceability: in a destination account you must be able to tell where a secret originated. Reversing this changes replicated secret names and tag values, which is disruptive to consumers, so it is recorded here to stop a well-meaning "fix" to destination-region semantics.

Behavior is unchanged when `add_region_prefix_to_name = false`.

_Harvested from the retired `specs/aws-secretsmanager-replication/001-fix-origin-region-prefix`._
