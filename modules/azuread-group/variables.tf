variable "name" {   
    description = "The name of the Azure AD group"
   
    type        = string 
}

variable "description" {
    description = "The description of the Azure AD group"
   
    type        = string
}

variable "members" {
    description = "The list of Azure AD users, groups or service principals to assign to the group"
    
    type = list(object({
    
        type              = string
    
        email             = optional(string)

        display_name      = optional(string)
    
        object_id         = optional(string)

        pim = optional(object({
    
            enabled              = bool
    
            type                 = optional(string)
    
            expiration_hours     = optional(string)
    
            justification_needed = optional(bool)
    
        }))
    
    }))
}

variable "owners" {
    
    description = "The list of Azure AD users or service principal owners of the group"
    
    type = list(object({
    
        type                = string
        
        email               = optional(string)

        display_name        = optional(string)

        object_id           = optional(string)

        pim = optional(object({

            type                 = optional(string)

            expiration_hours     = optional(string)

            justification_needed = optional(bool)

        }), 
        {
            type                = "disabled"
        })
    
    }))

    default = []
}

variable "subscription" {
    description = "The subscription id"
    
    type        = string

    default = null
}

variable "subscription_roles" {
    description = "The list of built-in roles to assign to the group"
    
    type = list(object({
    
        scope            = string
    
        role_name        = string
    
    }))
}

variable "default_pim_duration" {
    
    description = "The default duration for PIM role assignments"
    
    type        = string
    
    default     = "12"
}

