locals {

    repository_data = jsonencode({
        name = var.name
        visibility = var.visibility
        allow_auto_merge = var.allow_auto_merge
        auth_strategy = var.auth_strategy
        description = var.description
        allow_merge_commit = var.allow_merge_commit
        allow_rebase_merge = var.allow_rebase_merge
        allow_squash_merge = var.allow_squash_merge
        allow_update_branch = var.allow_update_branch
        archived = var.archived
        delete_branch_on_merge = var.delete_branch_on_merge
        has_discussions = var.has_discussions
        has_downloads = var.has_downloads
        has_issues = var.has_issues
        has_projects = var.has_projects
        has_wiki = var.has_wiki
        is_template = var.is_template
        merge_commit_message = var.merge_commit_message
        merge_commit_title = var.merge_commit_title
        squash_merge_commit_message = var.squash_merge_commit_message
        squash_merge_commit_title = var.squash_merge_commit_title
        vulnerability_alerts = var.vulnerability_alerts
        web_commit_signoff_required = var.web_commit_signoff_required
        topics = var.topics
        default_branch = var.default_branch
        features = var.features
    })

    features = jsondecode(data.external.features.result.features)

    # // filter user managed files
    managed_features = flatten([
        for feature, feature_data in local.features : [
            
            for file in feature_data.files : file if file.userManaged
            
        ]
    ])

    auto_managed_features =  flatten([
        for feature, feature_data in local.features : [
            
            for file in feature_data.files : file if !file.userManaged
            
        ]
    ])

}
