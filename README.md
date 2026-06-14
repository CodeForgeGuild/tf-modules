# Terraform Modules

Reusable Terraform modules for managing GitHub organizations and repositories.

## Available Modules

### `github/repo`

General-purpose repository module. Supports private and public repos, team access control, GitHub Actions environments, variables and secrets.

```hcl
module "my_repo" {
  source = "github.com/CodeForgeGuild/tf-modules//modules/github/repo?ref=v1"

  name        = "my-service"
  description = "My service repository"
  visibility  = "private"

  teams = {
    "1234567" = "maintain"
    "9876543" = "admin"
  }

  environments = ["dev", "staging", "prod"]

  repo_variables = [
    { name = "REGION", value = "eu-west-1" }
  ]

  env_secrets = [
    { environment = "prod", name = "DB_PASSWORD", value = var.db_password }
  ]
}
```

| Variable | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | required | Repository name |
| `description` | `string` | required | Repository description |
| `visibility` | `string` | `"private"` | `public`, `private`, or `internal` |
| `has_issues` | `bool` | `false` | Enable Issues tab |
| `homepage_url` | `string` | `""` | Homepage URL |
| `topics` | `list(string)` | `[]` | Repository topics |
| `license_template` | `string` | `""` | SPDX license id (e.g. `mit`). Empty = no license |
| `delete_branch_on_merge` | `bool` | `false` | Auto-delete head branches after merge |
| `create_main_branch` | `bool` | `true` | Create and set `main` as default branch |
| `allow_reusable_workflows` | `bool` | `false` | Allow org-wide reuse of this repo's workflows |
| `teams` | `map(string)` | `{}` | Map of team ID → permission (`admin`, `maintain`, `push`, `triage`, `pull`) |
| `environments` | `list(string)` | `[]` | GitHub Actions environments to create |
| `repo_variables` | `list(object)` | `[]` | Actions variables scoped to the repository |
| `repo_secrets` | `list(object)` | `[]` | Actions secrets scoped to the repository |
| `env_variables` | `list(object)` | `[]` | Actions variables scoped to an environment |
| `env_secrets` | `list(object)` | `[]` | Actions secrets scoped to an environment |
| `versioning_labels` | `bool` | `true` | Create `increment-patch/minor/major` labels |
| `pages` | `object` | `null` | GitHub Pages config. Null disables Pages |

**Outputs:** `id`, `name`, `full_name`, `html_url`, `ssh_clone_url`, `http_clone_url`, `node_id`

---

### `github/team`

Creates a GitHub team and manages its members.

```hcl
module "backend_team" {
  source = "github.com/CodeForgeGuild/tf-modules//modules/github/team?ref=v1"

  name        = "backend"
  description = "Backend engineers"

  members = {
    "alice" = "maintainer"
    "bob"   = "member"
  }
}
```

| Variable | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | required | Team name |
| `description` | `string` | required | Team description |
| `privacy` | `string` | `"closed"` | `closed` (visible to org) or `secret` |
| `parent_team_id` | `number` | `null` | Parent team ID for nested teams |
| `members` | `map(string)` | `{}` | Map of GitHub username → role (`maintainer` or `member`) |

**Outputs:** `id`, `node_id`, `slug`, `name`

---

### `github/org`

Manages organization-wide settings and Actions variables.

```hcl
module "org" {
  source = "github.com/CodeForgeGuild/tf-modules//modules/github/org?ref=v1"

  billing_email = "devops@example.com"

  default_repository_permission   = "read"
  members_can_create_repositories = false

  dependabot_alerts_enabled_for_new_repositories           = true
  dependabot_security_updates_enabled_for_new_repositories = true
  dependency_graph_enabled_for_new_repositories            = true

  org_variables = {
    "REGION"     = "eu-west-1"
    "REGISTRY"   = "registry.example.com"
  }
}
```

| Variable | Type | Default | Description |
|---|---|---|---|
| `billing_email` | `string` | required | Billing email |
| `name` | `string` | `""` | Organization display name |
| `description` | `string` | `""` | Organization description |
| `default_repository_permission` | `string` | `"read"` | Base permission for all members |
| `members_can_create_repositories` | `bool` | `false` | Allow members to create repos |
| `members_can_fork_private_repositories` | `bool` | `false` | Allow forking private repos |
| `has_organization_projects` | `bool` | `true` | Enable org-level Projects |
| `has_repository_projects` | `bool` | `true` | Enable Projects on repos |
| `advanced_security_enabled_for_new_repositories` | `bool` | `false` | GHAS on new repos (requires license) |
| `dependabot_alerts_enabled_for_new_repositories` | `bool` | `true` | Dependabot alerts on new repos |
| `dependabot_security_updates_enabled_for_new_repositories` | `bool` | `true` | Dependabot security updates on new repos |
| `dependency_graph_enabled_for_new_repositories` | `bool` | `true` | Dependency graph on new repos |
| `secret_scanning_enabled_for_new_repositories` | `bool` | `false` | Secret scanning on new repos (requires GHAS) |
| `org_variables` | `map(string)` | `{}` | Organization-level Actions variables |
| `org_variables_visibility` | `string` | `"private"` | Variable visibility: `all`, `private`, or `selected` |

> Organization rulesets are intentionally not included — bypass actor IDs are org-specific and should be managed in the consuming project.

**Outputs:** `id`

---

### `github/public-repo`

Opinionated module for public open-source repositories. Extends `github/repo` with auto-generated Dependabot config, a release workflow, and a Trivy security scan workflow via [CodeForgeGuild/ci-actions](https://github.com/CodeForgeGuild/ci-actions).

```hcl
module "my_lib" {
  source = "github.com/CodeForgeGuild/tf-modules//modules/github/public-repo?ref=v1"

  name        = "my-library"
  description = "An open-source library"
  visibility  = "public"

  has_issues = true
}
```

| Variable | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | required | Repository name |
| `description` | `string` | required | Repository description |
| `visibility` | `string` | `"public"` | `public` or `private` |
| `has_issues` | `bool` | `false` | Enable Issues tab |
| `license_template` | `string` | `"mit"` | SPDX license id. Empty = no license |
| `pages` | `object` | workflow/main | GitHub Pages config. Null disables Pages |
| `dependabot_ecosystems` | `list(string)` | `["pip","terraform","github-actions"]` | Package ecosystems for Dependabot |
| `ci_actions_ref` | `string` | `"v0"` | Git ref for `CodeForgeGuild/ci-actions` workflows |

**Outputs:** `id`, `name`, `full_name`, `html_url`, `ssh_clone_url`, `http_clone_url`, `node_id`

---

### `gcp-github-telegram-bot`

Provisions a GCP VM and wires it to a GitHub repository via Workload Identity Federation and Actions secrets. Useful for self-hosted Telegram bots deployed from GitHub Actions.

See [modules/gcp-github-telegram-bot/README.md](modules/gcp-github-telegram-bot/README.md) for full documentation.

---

## Requirements

- Terraform / OpenTofu ≥ 1.5.0
- GitHub Provider ≥ 6.0 (`integrations/github`)
- A GitHub token or GitHub App with `repo` and `admin:org` permissions
