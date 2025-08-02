# Production Environment Terraform Configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  # For production, consider using GCS backend for state management
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/state/prd"
  # }
  
  # Local backend for learning purposes
  backend "local" {
    path = "prd.tfstate"
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Configure the Google Cloud Beta Provider
provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}