# Development Environment Outputs

output "foundation" {
  description = "Foundation module outputs for development"
  value       = module.foundation
}

output "environment_info" {
  description = "Development environment information"
  value = {
    environment = "dev"
    region      = var.region
    zone        = var.zone
    project_id  = var.project_id
  }
}