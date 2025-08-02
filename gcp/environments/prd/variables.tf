# Production Environment Variables

variable "project_id" {
  description = "The GCP project ID for production environment"
  type        = string
}

variable "region" {
  description = "The GCP region for production resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for production resources"
  type        = string
  default     = "us-central1-c"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "gcp-terraform-learning"
}

variable "additional_labels" {
  description = "Additional labels specific to production environment"
  type        = map(string)
  default = {
    cost_optimization = "disabled"
    auto_shutdown     = "disabled"
    monitoring_level  = "full"
    backup_enabled    = "true"
    high_availability = "true"
  }
}