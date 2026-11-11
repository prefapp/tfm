## Examples


For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples/basic) – Minimal AKS cluster deployment
- [With VNet](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples/with_vnet) – AKS cluster using a custom VNet/Subnet
- [Extra node pools](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples/extra_node_pools) – AKS with additional node pools
- [Autoscaling](https://github.com/prefapp/tfm/tree/main/modules/azure-aks/_examples/autoscaling) – AKS with autoscaler profile enabled


### Example values (YAML)

```yaml
# Example variables for AKS module
location: "westeurope"
resource_group_name: "my-rg"
tags_from_rg: false
tags:
	application: "common"
	env: "predev"
aks_kubernetes_version: "1.28.10"
aks_network_plugin: "azure"
aks_network_policy: "azure"
aks_network_dataplane: "azure"
aks_orchestrator_version: "1.28.10"
aks_prefix: "predev"
aks_sku_name: "Base"
aks_sku_tier: "Free"
key_vault_secrets_provider_enabled: true
secret_rotation_enabled: true
secret_rotation_interval: 30s
auto_upgrade_profile:
  node_os_upgrade_channel: "None"
  upgrade_channel: "none"
aks_upgrade_settings:
  override_settings:
	  force_upgrade: true
	  until: "2026-09-18T14:30:00Z"
default_node_pool:
  name: "myng"
  vm_size: "Standard_D8as_v5"
  count_of: "2"
  enable_auto_scaling: false
  max_pods: 110
  os_disk_size_gb: 256
  node_labels:
    nodepool-group: "myng"
  upgrade_settings:
    drain_timeout_in_minutes: 30
    node_soak_duration_in_minutes: 0
    max_surge: "10%"
auto_scaler_profile:
  balance_similar_node_groups: false
  daemonset_eviction_for_empty_nodes: false
  daemonset_eviction_for_occupied_nodes: true
  ignore_daemonsets_utilization: false
  max_empty_bulk_delete: 10
  expander: "least-waste"
  max_graceful_termination_sec: "1800"
  max_node_provision_time: "15m"
  ok_total_unready_count: 2
  max_total_unready_percentage: 10
  new_pod_scale_up_delay: "10s"
  scale_down_delay_after_add: "15m"
  scale_down_delay_after_delete: "10s"
  scale_down_delay_after_failure: "3m"
  scale_down_unneeded_time: "5m"
  scale_down_unready_time: "15m"
  scale_down_utilization_threshold: "0.7"
  scan_interval: "10s"
  skip_nodes_with_local_storage: false
  skip_nodes_with_system_pods: false
extra_node_pools :
	- name: "foo"
		pool_name: "captpre"
		vm_size: "Standard_F8s_v2"
		enable_auto_scaling: true
		max_count: 5
		min_count: 2
		max_pod_per_node: 30
		os_disk_type: "Managed"
		custom_labels:
			nodepool-group: "foo"
	- name: "bar"
		pool_name: "genhpa"
		vm_size: "Standard_D4as_v5"
		enable_auto_scaling: true
		min_count: 2
		max_count: 20
		max_pod_per_node: 110
		os_disk_type: "Managed"
		custom_labels:
			nodepool-group: "bar"
subnet_name: "internal"
vnet_name: "spoke-common-predev-vnet"
vnet_resource_group_name: "my-rg"
public_ip_name: "my-output-aks-public-ip"
acr_map:
	acrxxx: "/xxx/xxx/xxx"
	acryyy: "/yyy/yyy/yyy"
oidc_issuer_enabled: "true"
workload_identity_enabled: "true"
```

## Remote resources
 - Terraform: https://www.terraform.io/
 - Azure Kubernetes Service: https://azure.microsoft.com/en-us/services/kubernetes-service/
 - Terraform Azure Provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest
 - Azure Container Registry: https://azure.microsoft.com/en-us/services/container-registry/

## Support

For issues, questions, or contributions related to this module, please visit the [repository’s issue tracker](https://github.com/prefapp/tfm/issues)
