output "id" {
  description = "Repository database ID"
  value       = github_repository.repository.id
}

output "name" {
  description = "Repository name"
  value       = github_repository.repository.name
}

output "full_name" {
  description = "Repository full name (owner/name)"
  value       = github_repository.repository.full_name
}

output "html_url" {
  description = "Repository URL on GitHub"
  value       = github_repository.repository.html_url
}

output "ssh_clone_url" {
  description = "SSH clone URL"
  value       = github_repository.repository.ssh_clone_url
}

output "http_clone_url" {
  description = "HTTPS clone URL"
  value       = github_repository.repository.http_clone_url
}

output "node_id" {
  description = "GraphQL node ID"
  value       = github_repository.repository.node_id
}
