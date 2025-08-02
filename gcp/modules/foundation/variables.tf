# Foundation Module Variables

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
  
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID must not be empty."
  }
}

variable "region" {
  description = "The GCP region for resources (restricted to free tier eligible regions)"
  type        = string
  default     = "us-central1"
  
  validation {
    condition = contains([
      "us-west1",
      "us-central1", 
      "us-east1"
    ], var.region)
    error_message = "Region must be one of the free tier eligible regions: us-west1, us-central1, us-east1."
  }
}

variable "zone" {
  description = "The GCP zone for resources"
  type        = string
  default     = "us-central1-a"
  
  validation {
    condition = can(regex("^(us-west1|us-central1|us-east1)-[a-z]$", var.zone))
    error_message = "Zone must be in a free tier eligible region (us-west1, us-central1, or us-east1)."
  }
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
  
  validation {
    condition = contains([
      "dev",
      "stg", 
      "prd"
    ], var.environment)
    error_message = "Environment must be one of: dev, stg, prd."
  }
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "gcp-terraform-learning"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "enable_free_tier_only" {
  description = "Enforce free tier resource limits to prevent charges"
  type        = bool
  default     = true
}

variable "additional_labels" {
  description = "Additional labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "required_apis" {
  description = "List of required GCP APIs to enable"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}