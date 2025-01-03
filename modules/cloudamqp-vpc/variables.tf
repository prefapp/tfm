variable "cloudamqp_vpc" {
  description = "Map of cloudAMQP vpc configurations"
  type = map(object({
    name   = string
    region = string
    subnet = string
    tags   = optional(map(string))
  }))
}

variable "cloudamqp_vpc_connect" {
  description = "Map of cloudAMQP vpc_connect configurations"
  type = map(object({
    instance_id            = string
    region                 = string
    approved_subscriptions = optional(list(string))
    sleep                  = optional(number)
    timeout                = optional(number)
  }))
}
