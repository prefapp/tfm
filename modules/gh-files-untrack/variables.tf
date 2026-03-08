variable "config" {
  description = "Files to untrack from Terraform state (so they survive terraform destroy)"
  type = object({
    files = list(object({
      repository = string
      file       = string
    }))
  })
}
