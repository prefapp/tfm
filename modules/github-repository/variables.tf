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

variable "allow_auto_merge" {
  description = "Allow auto-merge"
  type        = bool
  default = false
}

variable "description" {
  description = "The description of the repository"
  type        = string
  default = "A Terraform managed repository"
}

variable "allow_merge_commit" {
  description = "Allow merge commit"
  type        = bool
  default = true
}

variable "allow_rebase_merge" {
  description = "Allow rebase merge"
  type        = bool
  default = true
}

variable "allow_squash_merge" {
  description = "Allow squash merge"
  type        = bool
  default = true
}

variable "allow_update_branch" {
  description = "Allow update branch"
  type        = bool
  default = true
}

variable "archived" {
  description = "Archived"
  type        = bool
  default = false
}

variable "delete_branch_on_merge" {
  description = "Delete branch on merge"
  type        = bool
  default = true
}

variable "has_discussions" {
  description = "Has discussions"
  type        = bool
  default = false
}

variable "has_downloads" {
  description = "Has downloads"
  type        = bool
  default = true
}

variable "has_issues" {
  description = "Has issues"
  type        = bool
  default = true
}

variable "has_projects" {
  description = "Has projects"
  type        = bool
  default = true
}

variable "has_wiki" {
  description = "Has wiki"
  type        = bool
  default = true
}

variable "is_template" {
  description = "Is template"
  type        = bool
  default = false
}

variable "merge_commit_message" {
  description = "Merge commit message"
  type        = string
  default = null
}

variable "merge_commit_title" {
  description = "Merge commit title"
  type        = string
  default = null
}

variable "topics" {
  description = "Topics"
  type        = list(string)
  default = []
}

variable "squash_merge_commit_message" {
  description = "Squash merge commit message"
  type        = string
  default = null
}

variable "squash_merge_commit_title" {
  description = "Squash merge commit title"
  type        = string
  default = null
}

variable "vulnerability_alerts" {
  description = "Vulnerability alerts"
  type        = bool
  default = false
}

variable "web_commit_signoff_required" {
  description = "Web commit signoff required"
  type        = bool
  default = false
}

variable "features" {
  description = "Features"
  type        = list(object({
    name = string
    version = string
  }))
  default = []
}

variable "auth_strategy" {
  description = "Auth strategy"
  type        = string
  default = "default"
}
