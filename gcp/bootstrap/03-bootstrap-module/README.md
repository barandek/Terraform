# Bootstrap Module - Terraform State Management

This module creates the necessary infrastructure for Terraform remote state management in GCP.

## What This Module Creates

- **GCS Buckets**: One for each environment (dev, stg, prd by default)
- **API Enablement**: Required GCP APIs (Storage, Resource Manager, Service Usage)
- **IAM Permissions**: Proper access controls for state buckets
- **Configuration Files**: Backend configs and migration scripts for each environment
- **Security Settings**: Versioning, lifecycle policies, and uniform bucket access

## Usage

### 1. Prerequisites

Ensure you have the necessary permissions (run the verification script first):
```bash
cd ..
./verify-privileges.sh -p YOUR_PROJECT_ID
```

### 2. Configure Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your project details
vim terraform.tfvars
```

### 3. Initialize and Apply

```bash
# Initialize Terraform (uses local state for bootstrap)
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Use Generated Files

After successful apply, you'll have:
- `../backend-{env}.hcl` - Backend configuration files
- `../terraform-backend-{env}.tf` - Complete Terraform backend configs
- `../migrate-to-remote-{env}.sh` - Migration scripts for existing environments

## Configuration Options

### Basic Configuration

```hcl
project_id = "my-gcp-project"
region     = "us-central1"
```

### Advanced Configuration

```hcl
project_id = "my-gcp-project"
region     = "us-central1"

# Custom environments
environments = ["dev", "staging", "production"]

# Custom bucket naming
bucket_prefix = "mycompany-tf-state"

# Lifecycle management
lifecycle_age_days = 60

# Custom labels
labels = {
  managed_by  = "terraform"
  purpose     = "state-storage"
  team        = "platform"
  cost_center = "engineering"
}
```

## Security Features

### Bucket Security
- **Uniform bucket-level access** enabled
- **Versioning** enabled by default
- **Lifecycle policies** to clean up old versions
- **Prevent destroy** lifecycle rule

### Access Control
- Project editors and owners have object admin access
- No public access allowed
- Encryption at rest (Google-managed keys)

## Generated Resources

### State Buckets
- **Naming**: `{project_id}-terraform-state-{environment}-{random_suffix}`
- **Location**: Configurable region (default: us-central1)
- **Storage Class**: STANDARD
- **Versioning**: Enabled
- **Lifecycle**: Delete old versions after 30 days (configurable)

### Configuration Files
- **Backend HCL**: Simple backend configuration
- **Terraform Files**: Complete backend configuration with providers
- **Migration Scripts**: Automated migration from local to remote state

## Migration Process

After running this bootstrap module:

1. **For new environments**: Use the generated `terraform-backend-{env}.tf` files
2. **For existing environments**: Run the generated migration scripts:
   ```bash
   ./migrate-to-remote-dev.sh
   ```

## Troubleshooting

### Common Issues

#### "Bucket already exists"
- Bucket names must be globally unique
- The module uses random suffixes to avoid conflicts
- If you see this error, destroy and re-apply

#### "API not enabled"
- The module enables required APIs automatically
- Wait a few minutes for API enablement to propagate
- Re-run `terraform apply` if needed

#### "Permission denied"
- Ensure you have the necessary IAM roles
- Run the privilege verification script
- Check the [privilege requirements](../PRIVILEGE-REQUIREMENTS.md)

### State File Location

This bootstrap module uses **local state** stored in `bootstrap.tfstate`. This is intentional and the only exception to using remote state, since we're creating the remote state infrastructure.

**Important**: Keep the `bootstrap.tfstate` file safe and backed up, as it contains the configuration for your state buckets.

## Cleanup

To destroy the bootstrap infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete your state buckets and any state files they contain. Make sure you have backups of all important state files before destroying.

## Integration with Other Modules

After running this bootstrap:

1. **Update environment configurations** to use remote state
2. **Run migration scripts** for existing environments  
3. **Configure CI/CD pipelines** to use the new backend configurations
4. **Share backend configurations** with your team

## Example Output

After successful apply:

```
state_buckets = {
  "dev" = {
    "location" = "us-central1"
    "name" = "my-project-terraform-state-dev-a1b2c3d4"
    "url" = "gs://my-project-terraform-state-dev-a1b2c3d4"
  }
  "prd" = {
    "location" = "us-central1"
    "name" = "my-project-terraform-state-prd-a1b2c3d4"
    "url" = "gs://my-project-terraform-state-prd-a1b2c3d4"
  }
  "stg" = {
    "location" = "us-central1"
    "name" = "my-project-terraform-state-stg-a1b2c3d4"
    "url" = "gs://my-project-terraform-state-stg-a1b2c3d4"
  }
}
```