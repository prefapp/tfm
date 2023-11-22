######################
# KUBERNETES CLUSTER #
######################

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#name
variable "aks_cluster_name" {
  type = string
  description = "(Required) The name of the Managed Kubernetes Cluster to create. Changing this forces a new resource to be created."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#location
variable "aks_location" {
  type = string
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#resource_group_name
variable "aks_resource_group_name" {
  type = string
  description = "(Required) The name of the Resource Group in which the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#dns_prefix
variable "aks_aks_dns_prefix" {
  type = string
  description = "(Required) DNS prefix specified when creating the managed cluster."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#kubernetes_version
variable "aks_kubernetes_version" {
  type = string
  description = "(Optional) The Kubernetes version to use for this Cluster. Defaults to the latest version."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#azure_policy_enabled
variable "aks_azure_policy_enabled" {
  type = bool
  description = "(Optional) Should Azure Policy be enabled on this Cluster? Defaults to false."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#automatic_channel_upgrade
variable "aks_automatic_channel_upgrade" {
  type = string
  default = false
  description = "(Optional) Should automatic channel upgrades be enabled on this Cluster? Defaults to false."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#sku_tier
variable "aks_sku_tier" {
  type = string
  default = "Free"
  description = "(Optional) The SKU Tier of the Managed Kubernetes Cluster. Defaults to Free."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#workload_identity_enabled
variable "aks_workload_identity_enabled" {
  type = bool
  default = true
  description = "(Optional) Should Workload Identity be enabled on this Cluster? Defaults to false."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#oidc_issuer_enabled
variable "aks_oidc_issuer_enabled" {
  type = bool
  default = true
  description = "(Optional) Should OIDC Issuer be enabled on this Cluster? Defaults to false."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#identity
variable "aks_identity_type" {
  type = string
  default = "SystemAssigned"
  description = "(Optional) The identity type of the Managed Kubernetes Cluster. Defaults to SystemAssigned."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_name" {
  type = string
  default = "default"
  description = "(Optional) The name of the default Node Pool. Defaults to default."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_enable_auto_scaling" {
  type = bool
  default = false
  description = "(Optional) Should Auto Scaling be enabled for this Node Pool? Defaults to false."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_min_count" {
  type = number
  default = 1
  description = "(Optional) The minimum number of nodes which should exist in this Node Pool. Defaults to 1."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_max_count" {
  type = number
  description = "(Optional) The maximum number of nodes which should exist in this Node Pool. Defaults to 3."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_node_count" {
  type = number
  default = 1
  description = "(Optional) The number of nodes which should exist in this Node Pool. Defaults to 1."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_vm_size" {
  type = string
  default = "Standard_D2s_v3"
  description = "(Optional) The Virtual Machine size to be used in this Node Pool. Defaults to Standard_D2s_v3."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_os_disk_type" {
  type = string
  default = "Managed"
  description = "(Optional) The OS Disk type to be used in this Node Pool. Defaults to Managed."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_os_disk_size_gb" {
  type = number
  default = 100
  description = "(Optional) The OS Disk size to be used in this Node Pool. Defaults to 30."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
variable "aks_default_node_pool_max_pods" {
  type = number
  default = 110
  description = "(Optional) The maximum number of pods which can run on a node in this Node Pool. Defaults to 30."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#key_vault_secrets_provider
variable "aks_key_vault_secrets_provider_enabled" {
  type = bool
  default = false
  description = "(Optional) Should Key Vault Secrets Provider be enabled on this Cluster? Defaults to false."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#key_vault_secrets_provider
variable "aks_key_vault_secrets_provider_interval" {
  type = string
  default = "2m"
  description = "(Optional) The interval to poll for secret rotation. This attribute is only set when secret_rotation is true. Defaults to 2m."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#network_profile
variable "aks_network_plugin" {
  type = string
  default = "azure"
  description = "(Optional) The Network Plugin used for building Kubernetes network. Defaults to azure."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#network_profile
variable "aks_service_cidr" {
  type = string
  default = "patch"
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#network_profile
variable "aks_dns_service_ip" {
  type = string
  description = "(Optional) The IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#tags
variable "tags" {
  type = map(string)
  default = {}
  description = "(Optional) A mapping of tags to assign to the resource."
}

################
# NODE POOL(S) #
################


# aks_node_pools = [
#     {
#         name = "nodepool1"
#         node_count = 1
#         vm_size = "Standard_F8s_v2"
#         os_disk_type = "Managed"
#         os_disk_size_gb = 30
#         max_pods = 110
#         enable_auto_scaling = true
#         min_count = 1
#         max_count = 3
#     },
#     {
#         name = "nodepool2"
#         node_count = 1
#         vm_size = "Standard_F8s_v2"
#         os_disk_type = "Managed"
#         os_disk_size_gb = 30
#         max_pods = 110
#         enable_auto_scaling = true
#         min_count = 1
#         max_count = 3
#     }
# ]



# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
variable "aks_node_pools" {
  type = any
  description = "values for node pools"
}

#################
# SUBNET (DATA) #
################# 

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet#virtual_network_name
variable "aks_vnet_name" {
  type = string
  description = "(Required) The name of the Virtual Network in which the Kubernetes Cluster should exist."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet#name
variable "aks_subnet_name" {
  type = string
  description = "(Required) The name of the Subnet in which the Kubernetes Cluster should exist."
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet#resource_group_name
variable "aks_vnet_name_resource_group" {
  type = string
  description = "(Required) The name of the Resource Group in which the Virtual Network exists."
}
