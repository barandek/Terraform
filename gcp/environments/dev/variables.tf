# Development Environment Variables

variable "project_id" {
  description = "The GCP project ID for development environment"
  type        = string
}

variable "region" {
  description = "The GCP region for development resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for development resources"
  type        = string
  default     = "us-central1-a"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "gcp-terraform-learning"
}

variable "additional_labels" {
  description = "Additional labels specific to development environment"
  type        = map(string)
  default = {
    cost_optimization = "enabled"
    auto_shutdown     = "enabled"
    monitoring_level  = "basic"
  }
}