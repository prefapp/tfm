variable "cloudamqp_vpc" {
  description = "Map of cloudAMQP vpc configurations"
  type = object({
    name   = string
    region = string
    subnet = string
    tags   = optional(list(string))
  })
}

variable "cloudamqp_vpc_connect" {
  description = "Map of cloudAMQP vpc_connect configurations"
  type = object({
    instance_id            = number
    region                 = string
    approved_subscriptions = optional(list(string))
    sleep                  = optional(number)
    timeout                = optional(number)
  })
}
