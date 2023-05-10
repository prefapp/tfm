variable "location" {
  description = "(Required) The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "env" {}
variable "cliente" {}
variable "producto" {}

variable "postgresql_name" {
  description = "(Required) The name which should be used for this PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created."
}

variable "postgresql_version" {
  description = "(Required) The version of PostgreSQL Flexible Server to use"
}

variable "postgresql_disk_size" {
  description = "The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, and 16777216."
}

variable "postgresql_sku_size" {
  description = "The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern."
}

variable "postgresql_maintenance_window_day_of_week" {
  description = "The day of week for maintenance window, where the week starts on a Sunday, i.e. Sunday = 0, Monday = 1. Defaults to 0."
}

variable "postgresql_maintenance_window_start_hour" {
  description = "The start hour for maintenance window. Defaults to 0."
}

variable "postgresql_maintenance_window_start_minute" {
  description = "The start minute for maintenance window. Defaults to 0."
}

variable "administrator_login" {
  description = "The Administrator login for the PostgreSQL Flexible Server."
}

variable "password_secret_name" {
  description = "The name of secret name into key vault."
}

variable "password_key_vault" {
  description = "The key vault name."
}

variable "password_key_vault_rg" {
  description = "The resource group of key vault."
}

variable "virtual_network_name" {
  description = "(Required) The virtual network name."
}

variable "virtual_network_subnet_name" {
  description = "(Required) The subnet into the virtual network name."
}

variable "virtual_network_rg" {
  description = "(Required) The resource group from the virtual network name."
}

variable "private_endpoint_network_policies_enabled" {
  description = "Enable or Disable network policies for the private endpoint on the subnet."
  default     = "false"
}

variable "subnet_service_endpoints" {
  description = "(Optional) The list of Service endpoints to associate with the subnet. Possible values include."
  default     = ["Microsoft.Storage"]
}

variable "backup_retention_days" {
  description = "(Optional) The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days."
  default     = "7"
}

variable "authentication_active_directory_auth_enabled" {
  description = "Whether or not Active Directory authentication is allowed to access the PostgreSQL Flexible Server."
  default     = "false"
}

variable "authentication_password_auth_enabled" {
  description = "Whether or not password authentication is allowed to access the PostgreSQL Flexible Server."
  default     = "true"
}
