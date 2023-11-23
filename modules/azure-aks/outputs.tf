output "unified_output" {
  value = <<-EOT

    ######################
    ####      AKS     ####
    ######################
    
    AKS Cluster Name:   ${local.input.aks.cluster_name}
    AKS Location:       ${local.input.aks.location}
    AKS Resource Group: ${local.input.aks.resource_group_name}
    AKS Cluster ID:     ${azurerm_kubernetes_cluster.kubernetes.id}
  
    AKS Kubernetes Version:   ${local.input.aks.kubernetes_version}
    AKS Azure Policy Enabled: ${local.input.aks.identity.azure_policy_enabled}
    AKS Auto Upgrade Channel: ${local.input.aks.automatic_channel_upgrade}
    AKS SKU Tier:             ${local.input.aks.sku_tier}
   
    AKS Workload Identity Enabled: ${local.input.aks.identity.workload_identity_enabled}
    AKS OIDC Issuer Enabled:       ${local.input.aks.identity.oidc_issuer_enabled}
    AKS Identity Type:             ${local.input.aks.identity.identity_type}

    AKS DNS Prefix:     ${local.input.aks.network.dns_prefix}
    AKS Network Plugin: ${local.input.aks.network.network_plugin}
    AKS Service CIDR:   ${local.input.aks.network.service_cidr}
    AKS DNS Service IP: ${local.input.aks.network.dns_service_ip}

    AKS Default Node Pool Name:            ${local.input.aks.default_node_pool.name}
    AKS Default Node Pool Node Count:      ${local.input.aks.default_node_pool.node_count}
    AKS Default Node Pool VM Size:         ${local.input.aks.default_node_pool.vm_size}
    AKS Default Node Pool OS Disk Type:    ${local.input.aks.default_node_pool.os_disk_type}
    AKS Default Node Pool OS Disk Size GB: ${local.input.aks.default_node_pool.os_disk_size_gb}
    AKS Default Node Pool Max Pods:        ${local.input.aks.default_node_pool.max_pods}

    AKS Key Vault Secrets Provider Enabled:  ${local.input.aks.key_vault_secrets.key_vault_secrets_provider_enabled}
    AKS Key Vault Secrets Provider Interval: ${local.input.aks.key_vault_secrets.key_vault_secrets_provider_interval}
    
    Tags: ${jsonencode(local.input.aks.tags)}

    ############################
    #### Extra node Pool(s) ####
    ############################
    
    ${join("\n", [
      for key, value in local.input.aks.extra_node_pools : 
      "- Node Pool '${key}':\n  - ID: ${azurerm_kubernetes_cluster_node_pool.node_pool[key].id}\n  - VM Size: ${value.vm_size}\n  - Node Count: ${value.node_count}\n  - Min Count: ${value.min_count}\n  - Max Count: ${value.max_count}\n  - OS Disk Type: ${value.os_disk_type}\n  - OS Disk Size GB: ${value.os_disk_size_gb}\n  - Max Pods: ${value.max_pods}\n  - Auto Scaling Enabled: ${value.enable_auto_scaling}\n  - Tags: ${jsonencode(value.tags)}\n  - Node Labels: ${jsonencode(value.node_labels)}\n"
    ])}

    ######################
    ####  VNET (DATA) ####
    ######################
    
    AKS Subnet Name:         ${local.input.aks.network.subnet.subnet_name}
    AKS VNET Name:           ${local.input.aks.network.subnet.vnet_name}
    AKS VNET Resource Group: ${local.input.aks.network.subnet.vnet_name_resource_group}
    AKS Subnet ID:           ${data.azurerm_subnet.aks_subnet.id}

  EOT
}
