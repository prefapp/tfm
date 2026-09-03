resource "github_organization_settings" "this" {
  billing_email    = var.config.billingEmail
  company          = var.config.company
  blog             = var.config.blog
  email            = var.config.email
  twitter_username = var.config.twitterUsername
  location         = var.config.location
  name             = var.config.name
  description      = var.config.description

  has_organization_projects     = var.config.hasOrganizationProjects
  has_repository_projects       = var.config.hasRepositoryProjects
  default_repository_permission = var.config.defaultRepositoryPermission

  members_can_create_repositories          = var.config.membersCanCreateRepositories
  members_can_create_public_repositories   = var.config.membersCanCreatePublicRepositories
  members_can_create_private_repositories  = var.config.membersCanCreatePrivateRepositories
  members_can_create_internal_repositories = var.config.membersCanCreateInternalRepositories
  members_can_create_pages                 = var.config.membersCanCreatePages
  members_can_create_public_pages          = var.config.membersCanCreatePublicPages
  members_can_create_private_pages         = var.config.membersCanCreatePrivatePages
  members_can_fork_private_repositories    = var.config.membersCanForkPrivateRepositories
  web_commit_signoff_required              = var.config.webCommitSignoffRequired

  advanced_security_enabled_for_new_repositories               = var.config.advancedSecurityEnabledForNewRepositories
  dependabot_alerts_enabled_for_new_repositories               = var.config.dependabotAlertsEnabledForNewRepositories
  dependabot_security_updates_enabled_for_new_repositories     = var.config.dependabotSecurityUpdatesEnabledForNewRepositories
  dependency_graph_enabled_for_new_repositories                = var.config.dependencyGraphEnabledForNewRepositories
  secret_scanning_enabled_for_new_repositories                 = var.config.secretScanningEnabledForNewRepositories
  secret_scanning_push_protection_enabled_for_new_repositories = var.config.secretScanningPushProtectionEnabledForNewRepositories
}
