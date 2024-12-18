# Global variables
variable "mongo_region" {
  description = "The mongo region"
  type        = string
}

variable "provider_name" {
  description = "The provider name"
  type        = string
}

variable "project_id" {
  description = "The project id"
  type        = string
}

# Endpoint seccion variables
variable "endpoint_name" {
  description = "Name of the Azure endpoint"
  type        = string
}

variable "endpoint_location" {
  description = "Location of the Azure endpoint"
  type        = string
}

variable "endpoint_resource_group_name" {
  description = "Name of the Azure endpoint resource group"
  type        = string
}

variable "endpoint_connection_is_manual_connection" {
  description = "Whether or not the endpoint's private service connection is manual"
  type        = bool
}

variable "endpoint_connection_request_message" {
  description = "Request message of the endpoint's private service connection"
  type        = string
}

# Azure seccion variables
variable "azure_subnet_id" {
  description = "The azure subnet id"
  type        = string
}
