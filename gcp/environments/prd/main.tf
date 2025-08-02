# Production Environment Main Configuration

# Foundation module for production environment
module "foundation" {
  source = "../../modules/foundation"

  project_id            = var.project_id
  region               = var.region
  zone                 = var.zone
  environment          = "prd"
  project_name         = var.project_name
  enable_free_tier_only = true  # Keep true for learning purposes
  additional_labels    = var.additional_labels
}

# Production-specific resources can be added here
# For example, production monitoring, backup configurations, etc.