module "azure_oidc" {
  source = "../../"

  data = {
    app_registrations = [
      {
        name  = "service_repositories"
        roles = ["AcrPush", "AcrPull"]
        scope = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/foo/providers/Microsoft.ContainerRegistry/registries/foo-registry"
        ]
        federated_credentials = [
          {
            subject = "repository_owner:prefapp"
            issuer  = "https://token.actions.githubusercontent.com"
          }
        ]
      }
    ]
  }
}

