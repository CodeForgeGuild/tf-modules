variable "name" {
  description = "Nombre del repositorio"
  type        = string
}

variable "description" {
  description = "Descripción del repositorio"
  type        = string
}

variable "visibility" {
  description = "Visibilidad del repositorio"
  type        = string
}

variable "pages" {
  description = "Configuración de GitHub Pages"
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

variable "has_issues" {
  description = "Has issues yes/no"
  type = bool
  default = false
}

