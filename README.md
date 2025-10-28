# Terraform Modules

This repository contains **reusable Terraform modules** designed to standardize and automate the configuration of GitHub repositories within the organization.
Each module encapsulates a specific piece of infrastructure logic to simplify management and ensure consistency across projects.    

### Available Modules

**1. GitHub Repository Module**

This module defines and configures a complete GitHub repository with a consistent setup, following organizational standards and best practices.

It automates the creation of:

- GitHub repository with predefined settings (merge rules, visibility, etc.)
- Default branch and labels
- Dependabot configuration
- CI/CD workflows (release and security scan)
- Security updates and vulnerability alerts


#### Features
| Feature                   | Description                                                                                                                               |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **Repository Settings**   | Enforces rules like allowing squash merges, deleting branches on merge, and disabling merge commits.                                      |
| **Branch Management**     | Creates the `main` branch and sets it as default.                                                                                         |
| **Labels**                | Automatically adds versioning labels (`increment-patch`, `increment-minor`, `increment-major`).                                           |
| **Dependabot**            | Configures Dependabot for Python, Terraform, and GitHub Actions with monthly updates.                                                     |
| **Security Updates**      | Enables Dependabot security alerts and vulnerability scanning.                                                                            |
| **Workflows Integration** | Adds reusable CI workflows for releases and Trivy scans from the [`ci-actions`](https://github.com/CodeForgeGuild/ci-actions) repository. |

#### Usage

To use this module in your Terraform configuration:

```hcl
module "repository" {
  source = "github.com/CodeForgeGuild/tf-modules//modules/github?ref=v0"

  name        = "my-awesome-repo"
  description = "An example repository managed by Terraform"
  visibility  = "public"

  has_issues = true

  pages = {
    build_type = "workflow"
    source = {
      branch = "main"
    }
  }
}
```

#### Example Output

Once applied, the module will:

- Create a GitHub repository with your chosen name and description.
- Configure standard repository settings.
- Set up the following files automatically:
    - .github/workflows/ci-release.yml
    - .github/workflows/ci-trivy.yml
    - .github/dependabot.yml

- Add versioning labels and enable security alerts.

#### Requirements

- Terraform ≥ 1.5.0
- GitHub Provider ≥ 6.0
- A valid GitHub personal access token with `repo` and `admin:repo_hook` permissions.