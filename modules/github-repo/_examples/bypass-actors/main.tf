module "repository" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-repo"

  config = {
    repository = {
      name     = "my-repo"
      autoInit = true
    }

    default_branch = {
      branch = "main"
    }

    branch_protections = [
      {
        branch                 = "main"
        requiredReviewersCount = 1
        enforceAdmins          = true

        # Actors that can bypass PR requirements (e.g. a CI app)
        bypassPullRequestAllowances = {
          apps  = ["fs-admin"]
          teams = ["devops-team"]
          users = ["release-manager"]
        }

        # Actors that can bypass push restrictions (e.g. dependency bot)
        # Set independently from bypassPullRequestAllowances
        pushAllowances = {
          apps  = ["dependabot"]
          teams = []
          users = []
        }
      },
    ]
  }
}
