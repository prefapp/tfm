variable "location" {
  description = "The location/region where the Application Gateway should be created."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Application Gateway."
  type        = string
}

variable "application_gateway" {
  description = "The Application Gateway object."
    type        = any
}

variable "public_ip" {
  description = "The Azure Public IP object."
  type        = any
}

variable "user_assigned_identity" {
  description = "The name of the User Assigned Identity."
  type        = string
}

variable "subnet" {
  description = "The subnet object."
  type        = any
}

variable "web_application_firewall_policy" {
  description = "The Web Application Firewall Policy object."
  type        = any
}
