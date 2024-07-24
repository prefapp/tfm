variable "name" {
  description = "The name of the repository"
  type        = string
}

variable "visibility" {
  description = "The visibility of the repository"
  type        = string
  default = "private"
}

variable "org" {
  description = "The organization of the repository"
  type        = string
}

variable "default_branch" {
  description = "The default branch of the repository"
  type        = string
  default = "main"
}
