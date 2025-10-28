
resource "github_repository" "repository" {

  name        = var.name
  description = var.description
  visibility  = var.visibility

  allow_auto_merge            = true
  allow_merge_commit          = false
  allow_rebase_merge          = true
  allow_squash_merge          = true
  allow_update_branch         = false
  archived                    = false
  auto_init                   = true
  delete_branch_on_merge      = true
  has_discussions             = false
  has_downloads               = false
  has_issues                  = var.has_issues
  has_projects                = false
  has_wiki                    = false

  archive_on_destroy = false
  vulnerability_alerts = true

  license_template = "mit"

  pages {
    build_type = var.pages.build_type
    source {
      branch = var.pages.source.branch
    }
  }

}

resource "github_branch" "main" {
  repository = github_repository.repository.name
  branch     = "main"
}

resource "github_branch_default" "default"{
  repository = github_repository.repository.name
  branch     = github_branch.main.branch
}

resource "github_issue_label" "labels" {
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
  repository  = github_repository.repository.name
  enabled     = true
}

resource "github_repository_file" "dependabot" {
  repository = github_repository.repository.name
  file       = ".github/dependabot.yml"
  content    = yamlencode({
    version = 2
    updates = [
      {
        package-ecosystem = "pip"
        directory = "/"
        schedule = {
          interval = "monthly"
        }
        open-pull-requests-limit = 5
        labels = ["patch"]
      },
      {
        package-ecosystem = "terraform"
        directory = "/"
        schedule = {
          interval = "monthly"
        }
        open-pull-requests-limit = 5
        labels = ["patch"]
      },
      {
        package-ecosystem = "github-actions"
        directory = "/"
        schedule = {
          interval = "monthly"
        }
        open-pull-requests-limit = 5
        labels = ["patch"]
      }
    ]
  })
  branch      = github_branch.main.branch
  commit_message = "Add Dependabot configuration"
}

resource "github_repository_file" "release" {
  repository     = github_repository.repository.name
  file           = ".github/workflows/ci-release.yml"
  branch         = github_branch.main.branch
  commit_message = "Add ci release action"

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
        uses: CodeForgeGuild/ci-actions/.github/workflows/release.yml@v0
        secrets:
          GH_TOKEN: $${{ secrets.GITHUB_TOKEN }}
  EOT
}

resource "github_repository_file" "trivy" {
  repository     = github_repository.repository.name
  file           = ".github/workflows/ci-trivy.yml"
  branch         = github_branch.main.branch
  commit_message = "Add ci trivy scan action"

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
        uses: CodeForgeGuild/ci-actions/.github/workflows/trivy-scan.yml@v0
  EOT
}
