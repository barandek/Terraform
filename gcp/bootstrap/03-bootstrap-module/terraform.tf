# Bootstrap Module - Creates state bucket and initial setup
# This runs with local state, then other environments use the created bucket

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Use local backend for bootstrap - this is the only exception
  backend "local" {
    path = "bootstrap.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}