# VARIABLES SECTION
variable "nsg" {
  description = "Network Security Group configuration"
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string))
  })
}

variable "rules" {
  description = "Network Security Rule configuration"
  type = map(any)
}

