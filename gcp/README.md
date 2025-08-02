# GCP Terraform Learning Project - Multi-Environment Setup

A comprehensive Terraform learning environment focused on Google Cloud Platform (GCP) services with support for multiple environments (dev, stg, prd). This project demonstrates production-ready patterns for managing infrastructure across different environments while staying within GCP's Always Free tier.

## Project Structure

```
terraform/gcp/
├── README.md                          # This file
├── modules/                           # Reusable Terraform modules
│   └── foundation/                    # Foundation module for common resources
│       ├── terraform.tf               # Provider configuration
│       ├── variables.tf               # Module variables
│       ├── locals.tf                  # Naming conventions and common config
│       ├── main.tf                    # Core resources (APIs, service accounts)
│       └── outputs.tf                 # Module outputs
├── environments/                      # Environment-specific configurations
│   ├── dev/                          # Development environment
│   │   ├── terraform.tf              # Dev provider and backend config
│   │   ├── variables.tf              # Dev-specific variables
│   │   ├── main.tf                   # Dev environment resources
│   │   ├── outputs.tf                # Dev outputs
│   │   └── terraform.tfvars.example  # Dev configuration example
│   ├── stg/                          # Staging environment
│   │   ├── terraform.tf              # Staging provider and backend config
│   │   ├── variables.tf              # Staging-specific variables
│   │   ├── main.tf                   # Staging environment resources
│   │   ├── outputs.tf                # Staging outputs
│   │   └── terraform.tfvars.example  # Staging configuration example
│   └── prd/                          # Production environment
│       ├── terraform.tf              # Production provider and backend config
│       ├── variables.tf              # Production-specific variables
│       ├── main.tf                   # Production environment resources
│       ├── outputs.tf                # Production outputs
│       └── terraform.tfvars.example  # Production configuration example
└── [legacy files]                    # Original files (can be removed)
```

## Environment-Specific Features

### Development (dev)
- **Zone**: us-central1-a
- **Network CIDR**: 10.0.0.0/16
- **Features**: Cost optimization enabled, auto-shutdown enabled, basic monitoring
- **State**: Local backend (dev.tfstate)

### Staging (stg)
- **Zone**: us-central1-b
- **Network CIDR**: 10.1.0.0/16
- **Features**: Enhanced monitoring, testing environment, auto-shutdown disabled
- **State**: Local backend (stg.tfstate)

### Production (prd)
- **Zone**: us-central1-c
- **Network CIDR**: 10.2.0.0/16
- **Features**: Full monitoring, backup enabled, high availability, no auto-shutdown
- **State**: Local backend (prd.tfstate) - consider GCS for real production

## Quick Start

### 1. Choose Your Environment

Navigate to the environment you want to work with:

```bash
# For development
cd terraform/gcp/environments/dev

# For staging
cd terraform/gcp/environments/stg

# For production
cd terraform/gcp/environments/prd
```

### 2. Configure Variables

```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your project details
# Required: Set your project_id
# Optional: Customize region, zone, labels
```

### 3. Authenticate with GCP

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Working with Multiple Environments

### Deploy All Environments

```bash
# Deploy development
cd environments/dev
terraform init && terraform apply

# Deploy staging
cd ../stg
terraform init && terraform apply

# Deploy production
cd ../prd
terraform init && terraform apply
```

### Environment Isolation

Each environment:
- Has its own state file (dev.tfstate, stg.tfstate, prd.tfstate)
- Uses different network CIDR ranges to prevent conflicts
- Has environment-specific labels and configurations
- Can use different GCP projects for complete isolation

## Module System

### Foundation Module

The foundation module (`modules/foundation/`) provides:
- **API Management**: Enables required GCP APIs
- **Service Accounts**: Environment-specific service accounts
- **Naming Conventions**: Consistent resource naming
- **Labels**: Common labeling strategy
- **Free Tier Limits**: Enforced resource constraints
- **Network Configuration**: Environment-specific network settings

### Using the Foundation Module

```hcl
module "foundation" {
  source = "../../modules/foundation"

  project_id            = var.project_id
  region               = var.region
  zone                 = var.zone
  environment          = "dev"  # or "stg", "prd"
  project_name         = var.project_name
  enable_free_tier_only = true
  additional_labels    = var.additional_labels
}
```

## Environment-Specific Configurations

### Network Isolation

| Environment | VPC CIDR | Main Subnet | Private Subnet | GKE Subnet |
|-------------|----------|-------------|----------------|------------|
| dev | 10.0.0.0/16 | 10.0.1.0/24 | 10.0.2.0/24 | 10.0.10.0/24 |
| stg | 10.1.0.0/16 | 10.1.1.0/24 | 10.1.2.0/24 | 10.1.10.0/24 |
| prd | 10.2.0.0/16 | 10.2.1.0/24 | 10.2.2.0/24 | 10.2.10.0/24 |

### Resource Naming

Resources follow the pattern: `{environment}-{project_name}-{resource_type}`

Examples:
- `dev-gcp-terraform-learning-vm`
- `stg-gcp-terraform-learning-bucket`
- `prd-gcp-terraform-learning-cluster`

### Labels

Common labels applied to all resources:
- `environment`: dev/stg/prd
- `project`: gcp-terraform-learning
- `managed_by`: terraform
- `learning`: gcp-terraform-course
- `cost_center`: learning

Environment-specific labels:
- **Dev**: cost_optimization=enabled, auto_shutdown=enabled
- **Staging**: monitoring_level=enhanced, testing_env=true
- **Production**: backup_enabled=true, high_availability=true

## State Management

### Current Setup (Learning)
- **Backend**: Local
- **State Files**: Environment-specific (dev.tfstate, stg.tfstate, prd.tfstate)
- **Location**: Each environment directory

### Production Recommendation
For real production environments, consider:

```hcl
# In environments/prd/terraform.tf
backend "gcs" {
  bucket = "your-terraform-state-bucket"
  prefix = "terraform/state/prd"
}
```

## Free Tier Compliance

All environments are configured to stay within GCP's Always Free tier:

### Compute Engine
- **Instance Type**: f1-micro
- **Max Instances**: 1 per environment
- **Disk**: 30GB standard persistent disk

### Cloud Storage
- **Max Size**: 5GB per environment
- **Storage Class**: Standard

### Cloud Run
- **Memory**: 512Mi (dev/stg), 1Gi (prd)
- **CPU**: 1000m (dev/stg), 2000m (prd)
- **Max Instances**: 10 (dev/stg), 100 (prd)

## Adding New Modules

To add a new service module (e.g., compute, storage):

1. **Create Module Directory**
   ```bash
   mkdir -p modules/compute
   ```

2. **Create Module Files**
   ```bash
   touch modules/compute/{terraform.tf,variables.tf,main.tf,outputs.tf}
   ```

3. **Use in Environments**
   ```hcl
   module "compute" {
     source = "../../modules/compute"
     
     # Pass foundation outputs
     project_info = module.foundation.project_info
     common_labels = module.foundation.common_labels
     # ... other variables
   }
   ```

## Migration from Legacy Structure

If you have the old single-environment structure:

1. **Backup Current State**
   ```bash
   cp terraform.tfstate terraform.tfstate.backup
   ```

2. **Choose Target Environment**
   ```bash
   cd environments/dev  # or stg/prd
   ```

3. **Import Existing Resources** (if needed)
   ```bash
   terraform import google_project_service.required_apis["compute.googleapis.com"] your-project-id/compute.googleapis.com
   ```

## Troubleshooting

### State File Conflicts
- Each environment has its own state file
- No conflicts between environments
- Can run `terraform plan/apply` simultaneously

### Resource Naming Conflicts
- Environment prefix prevents naming conflicts
- Different network CIDRs prevent IP conflicts
- Separate service accounts per environment

### API Quotas
- Free tier quotas are per project, not per environment
- Consider using separate GCP projects for complete isolation
- Monitor usage in GCP Console

## Best Practices

### Development Workflow
1. **Develop in dev**: Test changes in development environment
2. **Validate in stg**: Promote tested changes to staging
3. **Deploy to prd**: Apply validated changes to production

### Code Organization
- Keep modules generic and reusable
- Environment-specific configurations in environment directories
- Use consistent naming and labeling

### Security
- Separate GCP projects for production isolation
- Use least-privilege service accounts
- Enable audit logging for production

### Cost Management
- Monitor free tier usage regularly
- Use labels for cost tracking
- Set up billing alerts

## Next Steps

1. **Deploy Foundation**: Start with one environment
2. **Add Service Modules**: Implement compute, storage, etc.
3. **Implement CI/CD**: Automate deployments
4. **Add Monitoring**: Implement comprehensive monitoring
5. **Security Hardening**: Add security best practices

## Support

For issues and questions:
1. Check environment-specific configurations
2. Verify module dependencies
3. Review state file locations
4. Check GCP project permissions