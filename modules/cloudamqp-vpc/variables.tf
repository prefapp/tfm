variable "cloudamqp_vpc" {
  description = "CloudAMQP vpc configurations"
  type = object({
    name   = string
    region = string
    subnet = string
    tags   = optional(list(string))
  })
}
