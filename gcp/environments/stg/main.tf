# Staging Environment Main Configuration

# Foundation module for staging environment
module "foundation" {
  source = "../../modules/foundation"

  project_id            = var.project_id
  region               = var.region
  zone                 = var.zone
  environment          = "stg"
  project_name         = var.project_name
  enable_free_tier_only = true
  additional_labels    = var.additional_labels
}

# Staging-specific resources can be added here
# For example, staging-specific monitoring, testing tools, etc.