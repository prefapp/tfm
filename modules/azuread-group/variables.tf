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
    
            type                 = optional(string)
    
            expiration_hours     = optional(string)

            permanent_assignment = optional(bool)
        }),
        {
            type                = "disabled"

            permanent_assignment = false
        })
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

            permanent_assignment = optional(bool)

        }), 
        {
            expiration_hours     = null

            type                 = "disabled"
            
            permanent_assignment = false

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
    
      role_name      = string
        
      resources_scopes = list(string)
    
  }))
}

variable "directory_roles" {
    
    description = "The list of directory roles to assign to the group"
    
    type = list(object({
    
        role_name = string
    
    }))
}

variable "default_pim_duration" {
    
    description = "The default duration for PIM role assignments"
    
    type        = string
    
    default     = "12"
}

variable "expiration_required" {
    
    description = "Indicates if the expiration is required for the PIM eligible role assignments"
    
    type        = bool
    
    default     = false
  
}

variable "pim_maximum_duration_hours" {
    
    description = "The maximum duration for PIM role assignments"
    
    type        = string
    
    default     = "8"
}

variable "pim_require_justification" {
    
    description = "Indicates if the justification is required for the eligible PIM role assignments"
    
    type        = bool
    
    default     = true
}

