variable "name" {
  description = "Repository name"
  type        = string
}

variable "description" {
  description = "Repository description"
  type        = string
}

variable "visibility" {
  description = "Repository visibility (public, private, internal)"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be public, private, or internal"
  }
}

variable "has_issues" {
  description = "Enable the Issues tab"
  type        = bool
  default     = false
}

variable "homepage_url" {
  description = "Repository homepage URL"
  type        = string
  default     = ""
}

variable "topics" {
  description = "Repository topics"
  type        = list(string)
  default     = []
}

variable "license_template" {
  description = "SPDX license template to apply (e.g. mit, apache-2.0). Empty string means no license."
  type        = string
  default     = ""
}

variable "delete_branch_on_merge" {
  description = "Automatically delete head branches after a PR is merged"
  type        = bool
  default     = false
}

variable "create_main_branch" {
  description = "Create the main branch and set it as default on first apply"
  type        = bool
  default     = true
}

variable "allow_reusable_workflows" {
  description = "Allow other repositories in the organization to use this repo's Actions workflows"
  type        = bool
  default     = false
}

variable "teams" {
  description = "Map of GitHub team ID to permission level (admin, maintain, push, triage, pull)"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for p in values(var.teams) : contains(["admin", "maintain", "push", "triage", "pull"], p)])
    error_message = "Each team permission must be one of: admin, maintain, push, triage, pull"
  }
}

variable "environments" {
  description = "GitHub Actions environments to create"
  type        = list(string)
  default     = []
}

variable "repo_variables" {
  description = "GitHub Actions variables scoped to the repository"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "repo_secrets" {
  description = "GitHub Actions secrets scoped to the repository"
  sensitive   = true
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "env_variables" {
  description = "GitHub Actions variables scoped to a specific environment"
  type = list(object({
    environment = string
    name        = string
    value       = string
  }))
  default = []
}

variable "env_secrets" {
  description = "GitHub Actions secrets scoped to a specific environment"
  sensitive   = true
  type = list(object({
    environment = string
    name        = string
    value       = string
  }))
  default = []
}

variable "versioning_labels" {
  description = "Create increment-patch, increment-minor, and increment-major labels for release automation"
  type        = bool
  default     = true
}

variable "pages" {
  description = "GitHub Pages configuration. Null disables Pages."
  type = object({
    build_type = string
    source = object({
      branch = string
    })
  })
  default = null
}
