## VARIABLES SECTION

variable "localnet" {
  description = "List of local network gateway objects"
  type = list(object({
    local_gateway_name          = string
    location                    = string
    resource_group_name         = string
    local_gateway_ip            = string
    local_gateway_address_space = list(string)
    tags_from_rg                = optional(bool)
    tags                        = optional(map(string))
  }))

  validation {
    condition     = length([for ln in var.localnet : ln.local_gateway_name]) == length(distinct([for ln in var.localnet : ln.local_gateway_name]))
    error_message = "Each entry in var.localnet must have a unique local_gateway_name value."
  }
  default = []
}
