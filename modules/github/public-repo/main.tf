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
  delete_branch_on_merge = true
  has_discussions        = false
  has_downloads          = false
  has_issues             = var.has_issues
  has_projects           = false
  has_wiki               = false
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
}

resource "github_branch" "main" {
  repository = github_repository.repository.name
  branch     = "main"
}

resource "github_branch_default" "default" {
  repository = github_repository.repository.name
  branch     = github_branch.main.branch
}

resource "github_issue_label" "versioning" {
  for_each = {
    "increment-patch" = { color = "1E90FF", description = "Increment patch" }
    "increment-minor" = { color = "9B59B6", description = "Increment minor" }
    "increment-major" = { color = "E67E22", description = "Increment major" }
  }

  repository  = github_repository.repository.name
  name        = each.key
  color       = each.value.color
  description = each.value.description
}

resource "github_repository_dependabot_security_updates" "dependabot" {
  repository = github_repository.repository.name
  enabled    = true
}

resource "github_repository_file" "dependabot" {
  repository = github_repository.repository.name
  file       = ".github/dependabot.yml"
  branch     = github_branch.main.branch
  commit_message = "Add Dependabot configuration"

  content = yamlencode({
    version = 2
    updates = [
      for ecosystem in var.dependabot_ecosystems : {
        package-ecosystem            = ecosystem
        directory                    = "/"
        schedule                     = { interval = "monthly" }
        open-pull-requests-limit     = 5
        labels                       = ["patch"]
      }
    ]
  })
}

resource "github_repository_file" "ci_release" {
  repository     = github_repository.repository.name
  file           = ".github/workflows/ci-release.yml"
  branch         = github_branch.main.branch
  commit_message = "Add CI release workflow"

  content = <<-EOT
    name: CI Release Version

    on:
      pull_request:
        types: [closed]
        branches: [main]

    permissions:
      contents: write
      pull-requests: read

    jobs:
      release:
        if: github.event.pull_request.merged == true
        uses: CodeForgeGuild/ci-actions/.github/workflows/release.yml@${var.ci_actions_ref}
        secrets:
          GH_TOKEN: $${{ secrets.GITHUB_TOKEN }}
  EOT
}

resource "github_repository_file" "ci_trivy" {
  repository     = github_repository.repository.name
  file           = ".github/workflows/ci-trivy.yml"
  branch         = github_branch.main.branch
  commit_message = "Add CI Trivy scan workflow"

  content = <<-EOT
    name: CI Trivy Scan

    on:
      pull_request:
        types: [opened, synchronize, reopened]
        branches: [main]

    permissions:
      contents: read
      pull-requests: write

    jobs:
      trivy:
        name: Trivy Scan
        uses: CodeForgeGuild/ci-actions/.github/workflows/trivy-scan.yml@${var.ci_actions_ref}
  EOT
}
