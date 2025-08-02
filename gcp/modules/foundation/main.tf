# Foundation Module Main Configuration

# Enable required APIs for the project
resource "google_project_service" "required_apis" {
  for_each = toset(var.required_apis)

  project = var.project_id
  service = each.value

  # Prevent accidental deletion of APIs
  disable_on_destroy = false
}

# Create environment-specific service account
resource "google_service_account" "environment_sa" {
  account_id   = "${var.environment}-learning-sa"
  display_name = "${title(var.environment)} Learning Service Account"
  description  = "Service account for ${var.environment} environment in GCP Terraform learning project"
  project      = var.project_id
}

# Environment-specific IAM roles for the service account
resource "google_project_iam_member" "environment_sa_roles" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/logging.viewer",
    "roles/monitoring.viewer"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.environment_sa.email}"
}

# Data source to get current project information
data "google_project" "current" {
  project_id = var.project_id
}

# Data source to get available zones in the selected region
data "google_compute_zones" "available" {
  region = var.region
}