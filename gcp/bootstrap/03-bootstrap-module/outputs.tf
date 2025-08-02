# Outputs for Bootstrap Module

output "state_buckets" {
  description = "Map of environment to state bucket details"
  value = {
    for env, bucket in google_storage_bucket.terraform_state : env => {
      name     = bucket.name
      url      = bucket.url
      location = bucket.location
    }
  }
}

output "backend_configurations" {
  description = "Backend configuration for each environment"
  value = {
    for env, bucket in google_storage_bucket.terraform_state : env => {
      bucket = bucket.name
      prefix = "terraform/state"
    }
  }
}

output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "enabled_apis" {
  description = "List of enabled APIs"
  value       = [for api in google_project_service.required_apis : api.service]
}