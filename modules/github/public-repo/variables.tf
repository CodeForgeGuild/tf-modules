variable "name" {
  description = "Repository name"
  type        = string
}

variable "description" {
  description = "Repository description"
  type        = string
}

variable "visibility" {
  description = "Repository visibility (public or private)"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "visibility must be public or private"
  }
}

variable "has_issues" {
  description = "Enable the Issues tab"
  type        = bool
  default     = false
}

variable "license_template" {
  description = "SPDX license template to apply (e.g. mit, apache-2.0). Empty string means no license."
  type        = string
  default     = "mit"
}

variable "pages" {
  description = "GitHub Pages configuration. Null disables Pages."
  type = object({
    build_type = string
    source = object({
      branch = string
    })
  })
  default = {
    build_type = "workflow"
    source = {
      branch = "main"
    }
  }
}

variable "dependabot_ecosystems" {
  description = "Package ecosystems to configure Dependabot for"
  type        = list(string)
  default     = ["pip", "terraform", "github-actions"]
}

variable "ci_actions_ref" {
  description = "Git ref for the CodeForgeGuild/ci-actions reusable workflows"
  type        = string
  default     = "v0"
}
