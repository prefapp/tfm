# Global variables
variable "location" {
  description = "The Azure location where all resources should be created"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
}

variable "tags_from_rg" {
  description = "Use resource group tags as base for module tags"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Data section public IP variables
variable "public_ip_name" {
  description = "The name of an existing public IP address in the same resource group as resource_group_name to use for the AKS load balancer outbound profile. This variable is only used when net_profile_outbound_type is set to 'loadBalancer'; for other values it is ignored. If null, AKS manages outbound IPs automatically."
  type        = string
  default     = null
}

# Data section subnet variables
variable "subnet_name" {
  description = "The name of the subnet to use for the AKS cluster"
}

variable "vnet_name" {
  description = "The name of the virtual network where the subnet is located"
}

variable "vnet_resource_group_name" {
  description = "The name of the resource group in which the virtual network is located"
}

# ACRs to link to AKS
variable "acr_map" {
  description = "The map of Azure Container Registries to link to the AKS cluster"
  type        = map(string)
  default     = {}
}

# AKS section variables
variable "aks_kubernetes_version" {
  description = "The version of Kubernetes to use for the AKS cluster"
}

variable "aks_network_plugin" {
  description = "The network plugin to use for networking in the AKS cluster"
}

variable "aks_network_dataplane" {
  description = "The network dataplane to use for the AKS cluster"
}

variable "aks_network_policy" {
  description = "The network policy to use for networking in the AKS cluster"
}

variable "aks_orchestrator_version" {
  description = "The version of Kubernetes to use for the AKS cluster"
}

variable "aks_prefix" {
  description = "The prefix for all resources in this example"
}

variable "aks_sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium"
}

variable "aks_sku_name" {
  description = "The SKU name that should be used for this Kubernetes Cluster. Possible values are Automatic and Base "
}

variable "key_vault_secrets_provider_enabled" {
  description = "Boolean value to activate the csi-secrets-store-driver"
}

variable "load_balancer_profile_enabled" {
  description = "Value to enable or not the load balancer profile"
  type        = bool
  default     = true
}

variable "load_balancer_sku" {
  description = "Load balancer sku (basic or standard)"
  type        = string
  default     = "standard"
}

variable "auto_upgrade_profile" {
  description  = "Auto upgrade profile for a managed cluster"
  type = object({
    node_os_upgrade_channel = optional(string, "NodeImage")
    upgrade_channel         = optional(string, "none")
  })
  default     = null
}

variable "oidc_issuer_enabled" {
  description = "Whether to enable OIDC Issuer for the AKS cluster"
  type        = bool
}

variable "secret_rotation_enabled" {
  description = "Boolean value to activate the secrets rotation csi-secrets-store-driver"
}

variable "secret_rotation_interval" {
  description = "String value to activate the secrets rotation interval csi-secrets-store-driver"
}


variable "workload_identity_enabled" {
  description = "Whether to enable Workload Identity for the AKS cluster"
}

variable "storage_profile" {
  description = "Storage profile for the AKS cluster"

  type = object({
    disk_csi_driver = optional(object({
      enabled = optional(bool, true)
    }))
    file_csi_driver = optional(object({
      enabled = optional(bool, true)
    }))
    snapshot_controller = optional(object({
      enabled = optional(bool, true)
    }))
  })
  default = {
    disk_csi_driver = {
      enabled = true
    }
    file_csi_driver = {
      enabled = true
    }
    snapshot_controller = {
      enabled = true
    }
  }
}

variable "support_plan" {
  description = "Support plan for the AKS cluster"
  type        = string
  default     = "KubernetesOfficial"
}

# Auto Scaler Profile
variable "auto_scaler_profile" {
  description = "Configuration for the AKS cluster autoscaler profile"

  type = object({
    balance_similar_node_groups          = optional(string, "false")
    daemonset_eviction_for_empty_nodes   = optional(bool, false)
    daemonset_eviction_for_occupied_nodes = optional(bool, true)
    expander                             = optional(string, "random")
    ignore_daemonsets_utilization        = optional(bool, false)
    max_empty_bulk_delete                = optional(string, "10")
    max_graceful_termination_sec         = optional(string, "600")
    max_node_provision_time              = optional(string, "15")
    max_total_unready_percentage         = optional(string, "0")
    new_pod_scale_up_delay               = optional(string, "0")
    ok_total_unready_count               = optional(string, "0")
    scale_down_delay_after_add            = optional(string, "10")
    scale_down_delay_after_delete         = optional(string, "10")
    scale_down_delay_after_failure        = optional(string, "3")
    scale_down_unneeded_time              = optional(string, "0")
    scale_down_unready_time               = optional(string, "0")
    scale_down_utilization_threshold      = optional(string, "0.5")
    scan_interval                         = optional(string, "10")
    skip_nodes_with_local_storage         = optional(string, "false")
    skip_nodes_with_system_pods           = optional(string, "false")
  })

  default = null
}

variable "net_profile_outbound_type" {
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster"
  type        = string
  default     = "loadBalancer"

  validation {
    condition     = contains(["loadBalancer", "userAssignedNATGateway", "userDefinedRouting", "managedNATGateway", "none"], var.net_profile_outbound_type)
    error_message = "You must use loadBalancer, userAssignedNATGateway, userDefinedRouting, managedNATGateway or none as outbound type value"
  }
}

# Default node pool variables
variable "default_node_pool" {
  description = "Configuration for the default AKS node pool"

  type = object({
    name                         = string
    vm_size                      = string
    count_of                     = number
    max_pods                     = number
    os_disk_size_gb              = number
    node_labels                  = optional(map(string), {})
    enable_auto_scaling          = optional(bool, false)

    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = optional(number, 30)
      node_soak_duration_in_minutes = optional(number, 0)
      max_surge                     = string
    }))
  })

  default = null
}

# Extra node pools variables
variable "extra_node_pools" {
  description = "A list of extra node pools to create"
  type = list(object({
    name                  = string
    pool_name             = string
    vm_size               = string
    count_of              = optional(number, 1)
    create_before_destroy = optional(bool, true)
    enable_auto_scaling   = optional(bool, false)
    min_count             = optional(number, null)
    max_count             = optional(number, null)
    max_pod_per_node      = optional(number, 110)
    os_disk_type          = optional(string, "Ephemeral")
    os_disk_size_gb       = optional(number)
    mode                  = optional(string, "User")
    custom_labels         = map(string)
    orchestrator_version  = optional(string, "")
    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = number
      node_soak_duration_in_minutes = number
      max_surge                     = string
    }))
  }))
  default = []
}

# API server authorized IP ranges
variable "api_server_authorized_ip_ranges" {
  description = "The IP ranges authorized to access the AKS API server"
  type        = list(string)
  default     = null
}

# Role assignment for public IP
variable "create_role_assignment_public_ip" {
  description = "Boolean value to create a role assignment for the public IP"
  type        = bool
  default     = false
}
