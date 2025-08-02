# Development Environment Main Configuration

# Foundation module for development environment
module "foundation" {
  source = "../../modules/foundation"

  project_id            = var.project_id
  region               = var.region
  zone                 = var.zone
  environment          = "dev"
  project_name         = var.project_name
  enable_free_tier_only = true
  additional_labels    = var.additional_labels
}

# Development-specific resources can be added here
# For example, development-only monitoring, logging configurations, etc.