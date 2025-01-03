variable "cloudamqp_vpc" {
  description = "CloudAMQP vpc configurations"
  type = object({
    name   = string
    region = string
    subnet = string
    tags   = optional(list(string))
  })
}

variable "cloudamqp_vpc_connect" {
  description = "CloudAMQP vpc_connect configurations"
  type = object({
    instance_id            = number
    region                 = string
    approved_subscriptions = optional(list(string))
    sleep                  = optional(number)
    timeout                = optional(number)
  })
}
