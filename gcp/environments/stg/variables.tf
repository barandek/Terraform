# Staging Environment Variables

variable "project_id" {
  description = "The GCP project ID for staging environment"
  type        = string
}

variable "region" {
  description = "The GCP region for staging resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for staging resources"
  type        = string
  default     = "us-central1-b"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "gcp-terraform-learning"
}

variable "additional_labels" {
  description = "Additional labels specific to staging environment"
  type        = map(string)
  default = {
    cost_optimization = "enabled"
    auto_shutdown     = "disabled"
    monitoring_level  = "enhanced"
    testing_env       = "true"
  }
}