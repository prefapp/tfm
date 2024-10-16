# Global variables
variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
}

variable "tags" {
  description = "The tags to associate with your resources"
  type        = map(string)
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

# Data section public IP variables
variable "public_ip_name" {
  description = "The name of the public IP address to use for the AKS cluster"
}

# ACRs to link to AKS
variable "acr_map" {
  description = "The map of Azure Container Registries to link to the AKS cluster"
  type        = map(string)
  default     = {}
}

# AKS section variables
variable "aks_agents_count" {
  description = "The number of agents in the AKS cluster"
}

variable "aks_agents_max_pods" {
  description = "The maximum number of pods that can run on an agent"
}

variable "aks_agents_pool_drain_timeout_in_minutes" {
  description = "The maximum time in minutes to wait for a node to drain during a node pool upgrade"
  default     = 30
}

variable "aks_agents_pool_max_surge" {
  description = "The maximum number of agents that can be added to the agent pool during an upgrade"
}

variable "aks_agents_pool_name" {
  description = "The name of the agent pool"
}

variable "aks_agents_size" {
  description = "The size of the agents in the AKS cluster"
}

variable "aks_default_pool_custom_labels" {
  description = "Default pool custom labels to apply to all nodes"
  type        = map(any)
  default     = {}
}

variable "aks_kubernetes_version" {
  description = "The version of Kubernetes to use for the AKS cluster"
}

variable "aks_network_plugin" {
  description = "The network plugin to use for networking in the AKS cluster"
}

variable "aks_network_policy" {
  description = "The network policy to use for networking in the AKS cluster"
}

variable "aks_orchestrator_version" {
  description = "The version of Kubernetes to use for the AKS cluster"
}

variable "aks_os_disk_size_gb" {
  description = "The size of the OS disk in GB"
}

variable "aks_prefix" {
  description = "The prefix for all resources in this example"
}

variable "aks_sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium"
}

variable "create_role_assignment_public_ip" {
  description = "Boolean value to create a role assignment for the public IP"
  type        = bool
  default     = false
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

variable "node_os_channel_upgrade" {
  description = "The automatic node channel upgrade setting for the AKS cluster"
  default     = "None"
}

variable "oidc_issuer_enabled" {
  description = "Whether to enable OIDC Issuer for the AKS cluster"
}

variable "secret_rotation_enabled" {
  description = "Boolean value to activate the secrets rotation csi-secrets-store-driver"
}

variable "secret_rotation_interval" {
  description = "String value to activate the secrets rotation interval csi-secrets-store-driver"
}

variable "temporary_name_for_rotation" {
  description = "Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing"
  default     = "temppool"
}

variable "workload_identity_enabled" {
  description = "Whether to enable Workload Identity for the AKS cluster"
}

# Extra node pools variables
variable "extra_node_pools" {
  description = "A list of extra node pools to create"
  type = list(object({
    create_before_destroy = optional(bool, true)
    custom_labels         = map(string)
    enable_auto_scaling   = optional(bool, false)
    max_count             = optional(number, null)
    max_pod_per_node      = optional(number, 110)
    min_count             = optional(number, null)
    mode                  = optional(string, "User")
    name                  = string
    node_count            = optional(number, 1)
    orchestrator_version  = optional(string, "")
    os_disk_type          = optional(string, "Ephemeral")
    pool_name             = string
    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = number
      max_surge                     = string
      node_soak_duration_in_minutes = number
    }))
    vm_size = string
  }))
  default = []
}

# Auto Scaler Profile
variable "auto_scaler_profile_enabled" {
  description = "Whether to enable the auto scaler profile"
  type        = bool
  default     = false
}

variable "auto_scaler_profile_expander" {
  description = "The expander to use for the auto scaler profile"
  type        = string
  default     = "random"
}

variable "auto_scaler_profile_max_graceful_termination_sec" {
  description = "The maximum graceful termination time in seconds for the auto scaler profile"
  type        = number
  default     = 600
}

variable "auto_scaler_profile_max_node_provisioning_time" {
  description = "The maximum node provisioning time in seconds for the auto scaler profile"
  type        = string
  default     = 15
}

variable "auto_scaler_profile_max_unready_nodes" {
  description = "The maximum number of unready nodes for the auto scaler profile"
  type        = number
  default     = 0
}

variable "auto_scaler_profile_max_unready_percentage" {
  description = "The maximum percentage of unready nodes for the auto scaler profile"
  type        = number
  default     = 0
}

variable "auto_scaler_profile_new_pod_scale_up_delay" {
  description = "The new pod scale up delay in seconds for the auto scaler profile"
  type        = string
  default     = 0
}

variable "auto_scaler_profile_scale_down_delay_after_add" {
  description = "The scale down delay after add in seconds for the auto scaler profile"
  type        = string
  default     = 10
}

variable "auto_scaler_profile_scale_down_delay_after_delete" {
  description = "The scale down delay after delete in seconds for the auto scaler profile"
  type        = string
  default     = 10
}

variable "auto_scaler_profile_scale_down_delay_after_failure" {
  description = "The scale down delay after failure in seconds for the auto scaler profile"
  type        = string
  default     = 3
}

variable "auto_scaler_profile_scale_down_unneeded" {
  description = "The scale down unneeded for the auto scaler profile"
  type        = string
  default     = 0
}

variable "auto_scaler_profile_scale_down_unready" {
  description = "The scale down unready for the auto scaler profile"
  type        = string
  default     = 0
}

variable "auto_scaler_profile_scale_down_utilization_threshold" {
  description = "The scale down utilization threshold for the auto scaler profile"
  type        = number
  default     = 0.5
}

variable "auto_scaler_profile_scan_interval" {
  description = "The scan interval for the auto scaler profile"
  type        = string
  default     = 10
}

variable "auto_scaler_profile_skip_nodes_with_local_storage" {
  description = "Whether to skip nodes with local storage for the auto scaler profile"
  type        = bool
  default     = false
}

variable "auto_scaler_profile_skip_nodes_with_system_pods" {
  description = "Whether to skip nodes with system pods for the auto scaler profile"
  type        = bool
  default     = false
}
