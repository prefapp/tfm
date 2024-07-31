// Retrieve the repository data
data "github_repository" "this" {
  name  = var.name
}

//  This is the data source that will be used to get the environment variables
data "external" "env_vars" {
    
    program = [
      
      "./scripts/get-env-vars.js", 
      
    ]
}


# // This is the data source that will be used to get the repository data
data "external" "features" {
  
  program = [
    
    "npx",

    "--yes",

    "@firestartr/features-renderer",
    
    local.repository_data,
    
  ]
}

data "github_repository_file" "user_managed_files" {
  for_each = { for file in local.managed_features: file.repoPath => file }
  repository          = var.name
  branch              = data.github_repository.this.id == null ? var.default_branch : data.github_repository.this.default_branch
  file                = each.value.repoPath
}
