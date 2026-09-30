variable "project_id" {
  description = "ID opcional del proyecto Public Cloud (project_id o service_name); tiene prioridad sobre project_name."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Nombre opcional del proyecto Public Cloud; se compara con project_name y description de OVHcloud."
  type        = string
  default     = null

  validation {
    condition     = var.project_name != null || var.project_id != null
    error_message = "Debes definir project_id o project_name para seleccionar el proyecto Public Cloud."
  }
}

variable "network_name" {
  description = "Nombre de la red privada que usará Kubernetes."
  type        = string
}

variable "gateway_name" {
  description = "Nombre del gateway de la red privada."
  type        = string
}

variable "region" {
  description = "Región OVHcloud en la que crear la red, por ejemplo EU-WEST-PAR o GRA11."
  type        = string
}

variable "vlan_id" {
  description = "VLAN de la red privada."
  type        = number
}

variable "network_cidr" {
  description = "CIDR privado de la subred."
  type        = string
}

variable "subnet_pool_start" {
  description = "Primera dirección del pool DHCP."
  type        = string
}

variable "subnet_pool_end" {
  description = "Última dirección del pool DHCP."
  type        = string
}

variable "gateway_model" {
  description = "Tamaño del gateway Public Cloud."
  type        = string
}
