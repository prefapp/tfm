# Global variables
variable "mongo_region" {
  description = "The mongo region"
  type        = string
}

# Project seccion variables
variable "org_id" {
  description = "The organization ID"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

# Cluster seccion variables
variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_type" {
  description = "The type of the cluster"
  type        = string
}

variable "cluster_replication_specs_config_analytics_nodes" {
  description = "The number of analytics nodes"
  type        = number
}

variable "cluster_replication_specs_config_electable_nodes" {
  description = "The number of electable nodes"
  type        = number
}

variable "cluster_replication_specs_config_priority" {
  description = "Priority value"
  type        = number
}

variable "cluster_replication_specs_config_read_only_nodes" {
  description = "The number of read only nodes"
  type        = number
}

variable "cluster_cloud_backup" {
  description = "Whether or not cloud backup is enabled"
  type        = bool
}

variable "cluster_auto_scaling_disk_gb_enabled" {
  description = "Whether or not disk autoscaling is enabled"
  type        = bool
}

variable "cluster_mongo_db_major_version" {
  description = "MongoDB major version"
  type        = string
}

variable "cluster_num_shards" {
  description = "The number of shards"
  type        = number
}

variable "cluster_zone" {
  description = "The zones of the cluster"
  type        = string
}

# Key Vault seccion variables
variable "key_vault_name" {
  description = "The key vault name"
  type        = string
}

variable "key_vault_resource_group_name" {
  description = "The key vault resource group name"
  type        = string
  default     = ""
}

# Users seccion variables
variable "users" {
  description = "List of users with their roles and scopes"
  type = list(object({
    username     = string
    auth_db_name = string
    roles = optional(list(object({
      role_name     = string
      database_name = string
    })))
    scopes = optional(list(object({
      name = string
      type = string
    })))
  }))
}

variable "password_length" {
  description = "The password length"
  type        = number
}

variable "password_special" {
  description = "Whether or not the password has special characters"
  type        = bool
}

variable "prefix_pass_name" {
  description = "The prefix of the password name"
  type        = string
}

# Provider seccion variables
variable "provider" {
  type = object({
    provider_name                       = string
    global_resource_group_name          = string
    cluster_provider_disk_type_name     = string
    cluster_provider_instance_size_name = string
    network = object({
      subnet_name                              = string
      vnet_name                                = string
      vnet_resource_group_name                 = string
      endpoint_name                            = string
      endpoint_location                        = string
      endpoint_resource_group_name             = string
      endpoint_connection_is_manual_connection = bool
      endpoint_connection_request_message      = string
    })
  })
}

# Endpoint seccion variables
variable "whitelist_ips" {
  description = "The whitelist IPs"
  type = list(object({
    ip   = string
    name = string
  }))
}

# Datadog api key seccion variables
variable "enabled_datadog_integration" {
  description = "Whether or not the Datadog integration is enabled"
  type        = bool
  default     = false
}

variable "datadog_api_key_name" {
  description = "The Datadog API key name"
  type        = string
  default     = ""
}
