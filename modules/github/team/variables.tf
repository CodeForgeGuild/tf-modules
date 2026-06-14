variable "name" {
  description = "Team name"
  type        = string
}

variable "description" {
  description = "Team description"
  type        = string
}

variable "privacy" {
  description = "Team visibility: closed (visible to all org members) or secret"
  type        = string
  default     = "closed"

  validation {
    condition     = contains(["closed", "secret"], var.privacy)
    error_message = "privacy must be closed or secret"
  }
}

variable "parent_team_id" {
  description = "ID of the parent team for nested teams. Null for top-level teams."
  type        = number
  default     = null
}

variable "members" {
  description = "Map of GitHub username to role (maintainer or member)"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for role in values(var.members) : contains(["maintainer", "member"], role)])
    error_message = "Each member role must be maintainer or member"
  }
}
