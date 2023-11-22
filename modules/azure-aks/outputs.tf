output "unified_output" {
  value = <<-EOT

    ######################
    ####      AKS     ####
    ######################
    
    AKS Cluster Name:   ${var.aks_cluster_name}
    AKS Location:       ${var.aks_location}
    AKS Resource Group: ${var.aks_resource_group_name}
    AKS Cluster ID:     ${azurerm_kubernetes_cluster.kubernetes.id}
  
    AKS Kubernetes Version:   ${var.aks_kubernetes_version}
    AKS Azure Policy Enabled: ${var.aks_azure_policy_enabled}
    AKS Auto Upgrade Channel: ${var.aks_automatic_channel_upgrade}
    AKS SKU Tier:             ${var.aks_sku_tier}
   
    AKS Workload Identity Enabled: ${var.aks_workload_identity_enabled}
    AKS OIDC Issuer Enabled:       ${var.aks_oidc_issuer_enabled}
    AKS Identity Type:             ${var.aks_identity_type}

    AKS DNS Prefix:     ${var.aks_aks_dns_prefix}
    AKS Network Plugin: ${var.aks_network_plugin}
    AKS Service CIDR:   ${var.aks_service_cidr}
    AKS DNS Service IP: ${var.aks_dns_service_ip}

    AKS Default Node Pool Name:            ${var.aks_default_node_pool_name}
    AKS Default Node Pool Node Count:      ${var.aks_default_node_pool_node_count}
    AKS Default Node Pool VM Size:         ${var.aks_default_node_pool_vm_size}
    AKS Default Node Pool OS Disk Type:    ${var.aks_default_node_pool_os_disk_type}
    AKS Default Node Pool OS Disk Size GB: ${var.aks_default_node_pool_os_disk_size_gb}
    AKS Default Node Pool Max Pods:        ${var.aks_default_node_pool_max_pods}

    AKS Key Vault Secrets Provider Enabled:  ${var.aks_key_vault_secrets_provider_enabled}
    AKS Key Vault Secrets Provider Interval: ${var.aks_key_vault_secrets_provider_interval}
    
    Tags: ${jsonencode(var.tags)}

    ######################
    #### Node Pool(s) ####
    ######################
    
    ${join("\n", [
      for key, value in var.aks_node_pools : 
      "- Node Pool '${key}':\n  - ID: ${azurerm_kubernetes_cluster_node_pool.node_pool[key].id}\n  - VM Size: ${value.vm_size}\n  - Node Count: ${value.node_count}\n  - Min Count: ${value.min_count}\n  - Max Count: ${value.max_count}\n  - OS Disk Type: ${value.os_disk_type}\n  - OS Disk Size GB: ${value.os_disk_size_gb}\n  - Max Pods: ${value.max_pods}\n  - Auto Scaling Enabled: ${value.enable_auto_scaling}\n  - Tags: ${jsonencode(value.tags)}\n  - Node Labels: ${jsonencode(value.node_labels)}\n"
    ])}

    ######################
    ####  VNET (DATA) ####
    ######################
    
    AKS Subnet Name:         ${var.aks_subnet_name}
    AKS VNET Name:           ${var.aks_vnet_name}
    AKS VNET Resource Group: ${var.aks_vnet_name_resource_group}
    AKS Subnet ID:           ${data.azurerm_subnet.aks_subnet.id}

  EOT
}
