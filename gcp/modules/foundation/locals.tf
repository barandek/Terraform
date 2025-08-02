# Local Values for Naming Conventions and Common Configuration

locals {
  # Naming Convention
  name_prefix = "${var.environment}-${var.project_name}"
  
  # Common Labels for All Resources
  common_labels = merge({
    environment    = var.environment
    project        = var.project_name
    managed_by     = "terraform"
    learning       = "gcp-terraform-course"
    cost_center    = "learning"
    created_by     = "terraform"
    terraform_path = path.cwd
  }, var.additional_labels)

  # Free Tier Resource Limits and Constraints
  free_tier_limits = {
    compute_engine = {
      instance_type     = "f1-micro"
      max_instances     = var.environment == "prd" ? 1 : 1  # Same for all envs in free tier
      eligible_regions  = ["us-west1", "us-central1", "us-east1"]
      disk_size_gb     = 30  # Standard persistent disk free tier limit
      disk_type        = "pd-standard"
    }
    
    cloud_storage = {
      max_size_gb      = 5
      storage_class    = "STANDARD"
      eligible_regions = ["us-west1", "us-central1", "us-east1"]
    }
    
    cloud_run = {
      max_requests_per_month = 2000000
      memory_limit          = var.environment == "prd" ? "1Gi" : "512Mi"
      cpu_limit            = var.environment == "prd" ? "2000m" : "1000m"
      max_instances        = var.environment == "prd" ? 100 : 10
      eligible_regions     = ["us-west1", "us-central1", "us-east1"]
    }
    
    cloud_functions = {
      max_invocations_per_month = 2000000
      memory_limit_mb          = var.environment == "prd" ? 512 : 256
      timeout_seconds          = var.environment == "prd" ? 120 : 60
      eligible_regions         = ["us-west1", "us-central1", "us-east1"]
    }
    
    gke = {
      max_nodes_per_cluster = var.environment == "prd" ? 3 : 1
      node_machine_type    = "e2-micro"  # Free tier eligible
      eligible_regions     = ["us-west1", "us-central1", "us-east1"]
    }
    
    cloud_logging = {
      retention_days = var.environment == "prd" ? 90 : 30
      max_gb_per_month = 50  # Free tier allotment
    }
  }

  # Resource Naming Patterns
  naming_patterns = {
    compute_instance = "${local.name_prefix}-vm"
    storage_bucket   = "${local.name_prefix}-bucket"
    cloud_run_service = "${local.name_prefix}-service"
    cloud_function   = "${local.name_prefix}-function"
    gke_cluster      = "${local.name_prefix}-cluster"
    vpc_network      = "${local.name_prefix}-vpc"
    subnet           = "${local.name_prefix}-subnet"
  }

  # Environment-specific Network Configuration
  network_config = {
    vpc_cidr = var.environment == "dev" ? "10.0.0.0/16" : var.environment == "stg" ? "10.1.0.0/16" : "10.2.0.0/16"
    subnet_cidrs = var.environment == "dev" ? {
      main    = "10.0.1.0/24"
      private = "10.0.2.0/24"
      gke     = "10.0.10.0/24"
    } : var.environment == "stg" ? {
      main    = "10.1.1.0/24"
      private = "10.1.2.0/24"
      gke     = "10.1.10.0/24"
    } : {
      main    = "10.2.1.0/24"
      private = "10.2.2.0/24"
      gke     = "10.2.10.0/24"
    }
    secondary_ranges = var.environment == "dev" ? {
      gke_pods     = "10.10.0.0/16"
      gke_services = "10.20.0.0/16"
    } : var.environment == "stg" ? {
      gke_pods     = "10.11.0.0/16"
      gke_services = "10.21.0.0/16"
    } : {
      gke_pods     = "10.12.0.0/16"
      gke_services = "10.22.0.0/16"
    }
  }
}