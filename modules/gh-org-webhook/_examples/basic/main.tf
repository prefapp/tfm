terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

module "org_webhook" {
  source = "../../"

  config = jsondecode(file("${path.module}/config.json")).config
}

output "webhook_id" {
  value = module.org_webhook.webhook_id
}
