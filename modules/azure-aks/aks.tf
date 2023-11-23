# Decode the YAML file into a Terraform data structure
locals {
  input = yamldecode(data.local_file.input.content) # Decodes the content of the YAML file into a Terraform data structure
}

# Use the decoded data in your resources
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "kubernetes" {
  name                      = local.input.aks.cluster_name # The name of the AKS cluster
  location                  = local.input.aks.location # The location where the AKS cluster will be created
  resource_group_name       = local.input.aks.resource_group_name # The name of the resource group where the AKS cluster will be created
  dns_prefix                = local.input.aks.network.dns_prefix # The DNS prefix for the AKS cluster
  kubernetes_version        = local.input.aks.kubernetes_version # The version of Kubernetes to use for the AKS cluster
  azure_policy_enabled      = local.input.aks.identity.azure_policy_enabled # Whether Azure Policy is enabled for the AKS cluster
  automatic_channel_upgrade = local.input.aks.automatic_channel_upgrade # Whether automatic channel upgrades are enabled for the AKS cluster
  sku_tier                  = local.input.aks.sku_tier # The SKU tier for the AKS cluster
  workload_identity_enabled = local.input.aks.identity.workload_identity_enabled # Whether workload identity is enabled for the AKS cluster
  oidc_issuer_enabled       = local.input.aks.identity.oidc_issuer_enabled # Whether OIDC issuer is enabled for the AKS cluster
  identity {
    type = local.input.aks.identity.identity_type # The type of identity used for the AKS cluster
  }
  default_node_pool {
    name                = local.input.aks.default_node_pool.name # The name of the default node pool
    enable_auto_scaling = local.input.aks.default_node_pool.enable_auto_scaling # Whether auto-scaling is enabled for the default node pool
    min_count           = local.input.aks.default_node_pool.enable_auto_scaling ? local.input.aks.default_node_pool.min_count : null # The minimum number of nodes for the default node pool if auto-scaling is enabled
    max_count           = local.input.aks.default_node_pool.enable_auto_scaling ? local.input.aks.default_node_pool.max_count : null # The maximum number of nodes for the default node pool if auto-scaling is enabled
    node_count          = local.input.aks.default_node_pool.node_count # The number of nodes in the default node pool
    vm_size             = local.input.aks.default_node_pool.vm_size # The size of the VMs in the default node pool
    os_disk_type        = local.input.aks.default_node_pool.os_disk_type # The type of OS disk for the default node pool
    os_disk_size_gb     = local.input.aks.default_node_pool.os_disk_size_gb # The size of the OS disk in GB for the default node pool
    max_pods            = local.input.aks.default_node_pool.max_pods # The maximum number of pods that can be run on a node in the default node pool
    vnet_subnet_id      = data.azurerm_subnet.aks_subnet.id # The ID of the subnet for the AKS cluster
  }
  key_vault_secrets_provider {
    secret_rotation_enabled  = local.input.aks.key_vault_secrets.key_vault_secrets_provider_enabled # Whether secret rotation is enabled for the Key Vault secrets provider
    secret_rotation_interval = local.input.aks.key_vault_secrets.key_vault_secrets_provider_interval # The interval for secret rotation for the Key Vault secrets provider
  }
  network_profile {
    network_plugin = local.input.aks.network.network_plugin # The network plugin to use for the AKS cluster
    service_cidr   = local.input.aks.network.service_cidr # The service CIDR for the AKS cluster
    dns_service_ip = local.input.aks.network.dns_service_ip # The DNS service IP for the AKS cluster
  }
  tags = local.input.aks.tags # The tags to apply to the AKS cluster
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count # Ignore changes to the node count of the default node pool
    ]
  }
}
