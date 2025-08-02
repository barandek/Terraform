# Staging Environment Outputs

output "foundation" {
  description = "Foundation module outputs for staging"
  value       = module.foundation
}

output "environment_info" {
  description = "Staging environment information"
  value = {
    environment = "stg"
    region      = var.region
    zone        = var.zone
    project_id  = var.project_id
  }
}