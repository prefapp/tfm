import {

  for_each = data.github_repository.this.id  != null ? [data.github_repository.this.name] : []

  to = github_repository.this

  id = var.name

}

import {

  for_each = data.github_repository.this.id  != null ? [data.github_repository.this.name] : []

  to = github_branch_default.this

  id = data.github_repository.this.name

}
