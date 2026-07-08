# Validation tests for the github-files-set module.
#
# These exercise the input validation on `var.config` without contacting the
# GitHub API by mocking the provider. The key case is `empty_config_files`:
# under the provision-once design a feature whose files are all userManaged
# reaches a steady state where config.files == [] while installed_managed_files
# is non-empty, and the module must accept that instead of failing.

mock_provider "github" {}

# config.files == [] is a legitimate steady state and must be accepted.
run "empty_config_files_is_allowed" {
  command = plan

  variables {
    installed_managed_files = ["README.md/main"]
    config = {
      repository = "org/my-repo"
      files      = []
    }
  }
}

# A normal, non-empty config still plans cleanly.
run "non_empty_config_is_allowed" {
  command = plan

  variables {
    installed_managed_files = []
    config = {
      repository = "org/my-repo"
      files = [
        {
          branch        = "main"
          commitMessage = "feat: add hello"
          content       = "# Hello"
          file          = "hello.md"
        },
      ]
    }
  }
}

# The remaining validations must still fire.
run "invalid_repository_is_rejected" {
  command = plan

  variables {
    installed_managed_files = []
    config = {
      repository = "not-a-valid-repo"
      files      = []
    }
  }

  expect_failures = [
    var.config,
  ]
}

run "duplicate_file_branch_is_rejected" {
  command = plan

  variables {
    installed_managed_files = []
    config = {
      repository = "org/my-repo"
      files = [
        {
          branch        = "main"
          commitMessage = "feat: add hello"
          content       = "# Hello"
          file          = "hello.md"
        },
        {
          branch        = "main"
          commitMessage = "feat: add hello again"
          content       = "# Hello again"
          file          = "hello.md"
        },
      ]
    }
  }

  expect_failures = [
    var.config,
  ]
}
