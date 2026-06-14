output "id" {
  description = "Team ID"
  value       = github_team.team.id
}

output "node_id" {
  description = "GraphQL node ID"
  value       = github_team.team.node_id
}

output "slug" {
  description = "Team slug (URL-friendly name)"
  value       = github_team.team.slug
}

output "name" {
  description = "Team name"
  value       = github_team.team.name
}
