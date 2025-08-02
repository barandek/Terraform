# Bootstrap Module - Creates Terraform state buckets and configuration

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "storage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  # Don't disable on destroy to avoid breaking existing resources
  disable_on_destroy = false
}

# Random suffix for bucket names to ensure uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create state buckets for each environment
resource "google_storage_bucket" "terraform_state" {
  for_each = toset(var.environments)

  name     = "${var.project_id}-${var.bucket_prefix}-${each.value}-${random_id.bucket_suffix.hex}"
  location = var.region
  
  # Storage class for cost optimization
  storage_class = "STANDARD"
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  # Enable versioning for state safety
  versioning {
    enabled = var.enable_versioning
  }

  # Lifecycle management to clean up old versions
  lifecycle_rule {
    condition {
      age                   = var.lifecycle_age_days
      with_state           = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age                   = var.lifecycle_age_days
      num_newer_versions   = 3
    }
    action {
      type = "Delete"
    }
  }

  # Security settings
  uniform_bucket_level_access = true
  
  # Encryption (Google-managed by default)
  encryption {
    default_kms_key_name = null
  }

  # Labels
  labels = merge(var.labels, {
    environment = each.value
  })

  depends_on = [google_project_service.required_apis]
}

# IAM binding to ensure proper access
resource "google_storage_bucket_iam_binding" "terraform_state_admin" {
  for_each = google_storage_bucket.terraform_state

  bucket = each.value.name
  role   = "roles/storage.objectAdmin"

  members = [
    "projectEditor:${var.project_id}",
    "projectOwner:${var.project_id}",
  ]
}

# Create backend configuration files for each environment
resource "local_file" "backend_configs" {
  for_each = google_storage_bucket.terraform_state

  filename = "${path.module}/../backend-${each.key}.hcl"
  content = templatefile("${path.module}/templates/backend.hcl.tpl", {
    bucket_name = each.value.name
    prefix      = "terraform/state"
  })

  file_permission = "0644"
}

# Create terraform backend configuration files
resource "local_file" "terraform_backend_configs" {
  for_each = google_storage_bucket.terraform_state

  filename = "${path.module}/../terraform-backend-${each.key}.tf"
  content = templatefile("${path.module}/templates/terraform-backend.tf.tpl", {
    bucket_name = each.value.name
    prefix      = "terraform/state"
    environment = each.key
  })

  file_permission = "0644"
}

# Create migration scripts
resource "local_file" "migration_scripts" {
  for_each = google_storage_bucket.terraform_state

  filename = "${path.module}/../migrate-to-remote-${each.key}.sh"
  content = templatefile("${path.module}/templates/migrate.sh.tpl", {
    bucket_name = each.value.name
    prefix      = "terraform/state"
    environment = each.key
    project_id  = var.project_id
  })

  file_permission = "0755"
}