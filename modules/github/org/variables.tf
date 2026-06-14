variable "billing_email" {
  description = "Billing email address for the organization"
  type        = string
}

variable "name" {
  description = "Display name of the organization"
  type        = string
  default     = ""
}

variable "description" {
  description = "Organization description"
  type        = string
  default     = ""
}

variable "default_repository_permission" {
  description = "Default permission for all org members on repositories (read, write, admin, none)"
  type        = string
  default     = "read"

  validation {
    condition     = contains(["read", "write", "admin", "none"], var.default_repository_permission)
    error_message = "default_repository_permission must be read, write, admin, or none"
  }
}

variable "members_can_create_repositories" {
  description = "Allow members to create repositories"
  type        = bool
  default     = false
}

variable "members_can_create_public_repositories" {
  description = "Allow members to create public repositories"
  type        = bool
  default     = false
}

variable "members_can_create_private_repositories" {
  description = "Allow members to create private repositories"
  type        = bool
  default     = false
}

variable "members_can_create_internal_repositories" {
  description = "Allow members to create internal repositories (requires Enterprise)"
  type        = bool
  default     = false
}

variable "members_can_fork_private_repositories" {
  description = "Allow members to fork private repositories"
  type        = bool
  default     = false
}

variable "members_can_create_pages" {
  description = "Allow members to create GitHub Pages sites"
  type        = bool
  default     = false
}

variable "members_can_create_public_pages" {
  description = "Allow members to create public GitHub Pages sites"
  type        = bool
  default     = false
}

variable "members_can_create_private_pages" {
  description = "Allow members to create private GitHub Pages sites"
  type        = bool
  default     = false
}

variable "has_organization_projects" {
  description = "Enable organization-level Projects"
  type        = bool
  default     = true
}

variable "has_repository_projects" {
  description = "Enable Projects on repositories"
  type        = bool
  default     = true
}

variable "web_commit_signoff_required" {
  description = "Require contributors to sign off on commits made through the GitHub web UI"
  type        = bool
  default     = false
}

variable "advanced_security_enabled_for_new_repositories" {
  description = "Enable GitHub Advanced Security for new repositories (requires GHAS license)"
  type        = bool
  default     = false
}

variable "dependabot_alerts_enabled_for_new_repositories" {
  description = "Enable Dependabot alerts on new repositories"
  type        = bool
  default     = true
}

variable "dependabot_security_updates_enabled_for_new_repositories" {
  description = "Enable Dependabot security updates on new repositories"
  type        = bool
  default     = true
}

variable "dependency_graph_enabled_for_new_repositories" {
  description = "Enable the dependency graph on new repositories"
  type        = bool
  default     = true
}

variable "secret_scanning_enabled_for_new_repositories" {
  description = "Enable secret scanning on new repositories (requires GHAS license)"
  type        = bool
  default     = false
}

variable "secret_scanning_push_protection_enabled_for_new_repositories" {
  description = "Enable secret scanning push protection on new repositories (requires GHAS license)"
  type        = bool
  default     = false
}

variable "org_variables" {
  description = "Map of GitHub Actions organization-level variable name to value"
  type        = map(string)
  default     = {}
}

variable "org_variables_visibility" {
  description = "Visibility of organization-level variables: all, private, or selected"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["all", "private", "selected"], var.org_variables_visibility)
    error_message = "org_variables_visibility must be all, private, or selected"
  }
}
