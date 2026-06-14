resource "github_repository" "repository" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_rebase_merge     = true
  allow_squash_merge     = true
  allow_update_branch    = false
  archived               = false
  auto_init              = true
  delete_branch_on_merge = var.delete_branch_on_merge
  has_discussions        = false
  has_downloads          = false
  has_issues             = var.has_issues
  has_projects           = false
  has_wiki               = false
  homepage_url           = var.homepage_url
  topics                 = var.topics
  vulnerability_alerts   = true
  archive_on_destroy     = false

  license_template = var.license_template != "" ? var.license_template : null

  dynamic "pages" {
    for_each = var.pages != null ? [var.pages] : []
    content {
      build_type = pages.value.build_type
      source {
        branch = pages.value.source.branch
      }
    }
  }

  lifecycle {
    ignore_changes = [pages]
  }
}

locals {
  default_branch = var.create_main_branch ? github_branch.main[0].branch : "main"
}

resource "github_branch" "main" {
  count      = var.create_main_branch ? 1 : 0
  repository = github_repository.repository.name
  branch     = "main"
}

resource "github_branch_default" "default" {
  count      = var.create_main_branch ? 1 : 0
  repository = github_repository.repository.name
  branch     = local.default_branch
}

resource "github_actions_repository_access_level" "reusable_workflows" {
  count        = var.allow_reusable_workflows ? 1 : 0
  access_level = "organization"
  repository   = github_repository.repository.name
}

resource "github_actions_repository_permissions" "actions" {
  repository      = github_repository.repository.name
  allowed_actions = "all"
}

resource "github_team_repository" "teams" {
  for_each   = var.teams
  team_id    = each.key
  repository = github_repository.repository.name
  permission = each.value
}

resource "github_issue_label" "versioning" {
  for_each = var.versioning_labels ? {
    "increment-patch" = { color = "1E90FF", description = "Increment patch" }
    "increment-minor" = { color = "9B59B6", description = "Increment minor" }
    "increment-major" = { color = "E67E22", description = "Increment major" }
  } : {}

  repository  = github_repository.repository.name
  name        = each.key
  color       = each.value.color
  description = each.value.description
}

resource "github_repository_dependabot_security_updates" "dependabot" {
  repository = github_repository.repository.name
  enabled    = true
}

resource "github_repository_environment" "envs" {
  for_each    = toset(var.environments)
  repository  = github_repository.repository.name
  environment = each.key
}

resource "github_actions_variable" "repo_vars" {
  for_each      = { for v in var.repo_variables : v.name => v }
  repository    = github_repository.repository.name
  variable_name = each.value.name
  value         = each.value.value
}

resource "github_actions_secret" "repo_secrets" {
  for_each        = { for s in var.repo_secrets : s.name => s }
  repository      = github_repository.repository.name
  secret_name     = each.value.name
  plaintext_value = each.value.value
}

resource "github_actions_environment_variable" "env_vars" {
  for_each = { for v in var.env_variables : "${v.environment}:${v.name}" => v }

  depends_on    = [github_repository_environment.envs]
  repository    = github_repository.repository.name
  environment   = each.value.environment
  variable_name = each.value.name
  value         = each.value.value
}

resource "github_actions_environment_secret" "env_secrets" {
  for_each = { for s in var.env_secrets : "${s.environment}:${s.name}" => s }

  depends_on      = [github_repository_environment.envs]
  repository      = github_repository.repository.name
  environment     = each.value.environment
  secret_name     = each.value.name
  plaintext_value = each.value.value
}
