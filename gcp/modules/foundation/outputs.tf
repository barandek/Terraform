# Foundation Module Outputs

output "project_info" {
  description = "Project configuration information"
  value = {
    project_id   = var.project_id
    region       = var.region
    zone         = var.zone
    environment  = var.environment
    project_name = var.project_name
  }
}

output "common_labels" {
  description = "Common labels applied to all resources"
  value       = local.common_labels
}

output "name_prefix" {
  description = "Common naming prefix for resources"
  value       = local.name_prefix
}

output "free_tier_limits" {
  description = "Free tier resource limits and constraints"
  value       = local.free_tier_limits
  sensitive   = false
}

output "naming_patterns" {
  description = "Resource naming patterns"
  value       = local.naming_patterns
}

output "network_config" {
  description = "Network configuration for the environment"
  value       = local.network_config
}

output "service_account" {
  description = "Environment service account information"
  value = {
    email = google_service_account.environment_sa.email
    name  = google_service_account.environment_sa.name
    id    = google_service_account.environment_sa.account_id
  }
}

output "enabled_apis" {
  description = "List of enabled APIs"
  value       = [for api in google_project_service.required_apis : api.service]
}

output "project_data" {
  description = "Current project data"
  value = {
    number = data.google_project.current.number
    name   = data.google_project.current.name
  }
}

output "available_zones" {
  description = "Available zones in the selected region"
  value       = data.google_compute_zones.available.names
}