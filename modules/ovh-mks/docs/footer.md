## Import and Lifecycle

The module manages these Terraform resources:

- Cluster: `module.ovh_mks.ovh_cloud_project_kube.production`
- Node pool: `module.ovh_mks.ovh_cloud_project_kube_nodepool.production["<pool-key>"]`

The addresses above assume the caller names the module `ovh_mks`; use the actual module block name in your Terraform state.

To import an existing cluster, use the OVHcloud Public Cloud `service_name` and cluster ID:

```sh
terraform import 'module.ovh_mks.ovh_cloud_project_kube.production' '<service_name>/<cluster_id>'
```

To import a node pool, use its `service_name`, cluster ID, and pool ID. Repeat for each pool, replacing `<pool-key>` with the key from `node_pools`:

```sh
terraform import 'module.ovh_mks.ovh_cloud_project_kube_nodepool.production["<pool-key>"]' '<service_name>/<cluster_id>/<pool_id>'
```

Destroying the module deletes its managed node pools and MKS cluster; it does not delete the separately managed private network, subnet, or gateway. Changing the selected network/subnet or cluster region can require cluster reset or replacement and may destroy cluster data. OVHcloud currently does not implement in-place migration between the `free` and `standard` plans, so do not assume changing `cluster_plan` will upgrade an existing cluster.

Before destructive changes, migrate workloads and back up any data that must be retained, including persistent-volume data according to its storage lifecycle. Review the Terraform plan carefully before applying cluster, pool, or network changes.

## Examples

The examples are self-contained Terraform configurations that call this module:

- [Paris multi-zone](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks/_examples/multi-zone) — standard cluster with one node pool per availability zone.
- [Gravelines single pool](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks/_examples/single-pool) — standard cluster with one pool and no zone pinned.
- [Free cluster without workers](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks/_examples/free-no-workers) — free control plane and a node pool scaled to zero.

## Resources

- **OVHcloud Managed Kubernetes Service**: [Product documentation](https://www.ovhcloud.com/en/public-cloud/kubernetes/)
- **OVHcloud Terraform provider**: [`ovh_cloud_project_kube`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube) and [`ovh_cloud_project_kube_nodepool`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_nodepool)
- **OVHcloud Terraform provider data sources**: [Provider documentation](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- **OVHcloud private network module**: [`ovh-network`](https://github.com/prefapp/tfm/tree/main/modules/ovh-network)

## Support

For questions, issues, or contributions related to this module, visit the [repository issue tracker](https://github.com/prefapp/tfm/issues).
