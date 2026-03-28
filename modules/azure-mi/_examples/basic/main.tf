module "azure_mi" {
  source = "../../"

  name          = "example-mi"
  resource_group = "example-rg"
  location      = "westeurope"

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  rbac = [
    {
      name  = "example-rbac"
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg"
      roles = ["Reader"]
    }
  ]

  access_policies = []

  federated_credentials = [
    {
      name         = "example-github"
      type         = "github"
      organization = "example-org"
      repository   = "example-repo"
      entity       = "ref:refs/heads/main"
    }
  ]
}
