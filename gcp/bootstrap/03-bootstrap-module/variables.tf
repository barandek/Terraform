# Variables for Bootstrap Module

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "environments" {
  description = "List of environments to create state buckets for"
  type        = list(string)
  default     = ["dev", "stg", "prd"]
}

variable "bucket_prefix" {
  description = "Prefix for state bucket names"
  type        = string
  default     = "terraform-state"
}

variable "enable_versioning" {
  description = "Enable versioning on state buckets"
  type        = bool
  default     = true
}

variable "lifecycle_age_days" {
  description = "Number of days after which to delete old versions"
  type        = number
  default     = 30
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    purpose    = "state-storage"
  }
}