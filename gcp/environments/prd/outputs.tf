# Production Environment Outputs

output "foundation" {
  description = "Foundation module outputs for production"
  value       = module.foundation
}

output "environment_info" {
  description = "Production environment information"
  value = {
    environment = "prd"
    region      = var.region
    zone        = var.zone
    project_id  = var.project_id
  }
}