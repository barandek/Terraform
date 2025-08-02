# Project Structure Overview

This document provides a quick overview of the multi-environment Terraform structure.

## Directory Structure

```
terraform/gcp/
├── README.md                    # Main documentation
├── MIGRATION.md                 # Migration guide from single-env setup
├── STRUCTURE.md                 # This file
├── .gitignore                   # Git ignore rules
├── modules/                     # Reusable Terraform modules
│   └── foundation/              # Foundation module (APIs, service accounts, etc.)
│       ├── terraform.tf         # Provider requirements
│       ├── variables.tf         # Module input variables
│       ├── locals.tf            # Local values and naming conventions
│       ├── main.tf              # Main resources
│       └── outputs.tf           # Module outputs
├── environments/                # Environment-specific configurations
│   ├── dev/                     # Development environment
│   │   ├── terraform.tf         # Provider and backend config
│   │   ├── variables.tf         # Environment variables
│   │   ├── main.tf              # Environment resources (uses foundation module)
│   │   ├── outputs.tf           # Environment outputs
│   │   └── terraform.tfvars.example  # Configuration template
│   ├── stg/                     # Staging environment (same structure as dev)
│   └── prd/                     # Production environment (same structure as dev)
└── scripts/                     # Helper scripts
    ├── manage-env.sh            # Bash script for environment management
    └── manage-env.ps1           # PowerShell script for environment management
```

## Key Concepts

### 🏗️ **Modules**
- **Foundation Module**: Contains common resources shared across all environments
- **Reusable**: Can be used by any environment with different parameters
- **Consistent**: Ensures all environments follow the same patterns

### 🌍 **Environments**
- **Isolated**: Each environment has its own state file and configuration
- **Customizable**: Environment-specific variables and settings
- **Scalable**: Easy to add new environments (qa, demo, etc.)

### 📁 **State Management**
- **Separate States**: Each environment maintains its own Terraform state
- **No Conflicts**: Environments can be deployed independently
- **Local Backend**: Using local state files for learning (consider remote for production)

## Quick Commands

### Using Helper Scripts

```bash
# Bash (Linux/macOS)
./scripts/manage-env.sh <env> <action>
./scripts/manage-env.sh dev init
./scripts/manage-env.sh dev plan
./scripts/manage-env.sh dev apply

# PowerShell (Windows)
.\scripts\manage-env.ps1 <env> <action>
.\scripts\manage-env.ps1 dev init
.\scripts\manage-env.ps1 dev plan
.\scripts\manage-env.ps1 dev apply
```

### Manual Commands

```bash
# Navigate to environment
cd environments/dev  # or stg/prd

# Standard Terraform workflow
terraform init
terraform plan
terraform apply
```

## Environment Differences

| Aspect | Dev | Staging | Production |
|--------|-----|---------|------------|
| **Zone** | us-central1-a | us-central1-b | us-central1-c |
| **Network** | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| **State File** | dev.tfstate | stg.tfstate | prd.tfstate |
| **Auto-shutdown** | ✅ Enabled | ❌ Disabled | ❌ Disabled |
| **Monitoring** | Basic | Enhanced | Full |
| **Backup** | ❌ Disabled | ❌ Disabled | ✅ Enabled |

## Adding New Environments

To add a new environment (e.g., `qa`):

1. **Copy Environment Template**:
   ```bash
   cp -r environments/dev environments/qa
   ```

2. **Update Configuration**:
   - Edit `environments/qa/main.tf` to set `environment = "qa"`
   - Update `environments/qa/variables.tf` with qa-specific defaults
   - Modify `environments/qa/terraform.tf` backend path to `qa.tfstate`

3. **Configure Variables**:
   ```bash
   cd environments/qa
   cp terraform.tfvars.example terraform.tfvars
   # Edit with qa-specific values
   ```

4. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Best Practices

### 🔄 **Development Workflow**
1. **Develop** → Test changes in `dev` environment
2. **Validate** → Promote to `stg` for integration testing  
3. **Deploy** → Apply to `prd` after validation

### 🏷️ **Resource Naming**
- **Pattern**: `{environment}-{project_name}-{resource_type}`
- **Example**: `dev-gcp-terraform-learning-vm`
- **Consistent**: All resources follow the same naming convention

### 🔒 **Security**
- **Separate Projects**: Consider using different GCP projects per environment
- **Least Privilege**: Environment-specific service accounts with minimal permissions
- **State Security**: Protect state files (consider remote backends for production)

### 💰 **Cost Management**
- **Free Tier**: All environments configured to stay within GCP free tier
- **Monitoring**: Use labels for cost tracking and resource management
- **Cleanup**: Regularly destroy unused development resources

## Troubleshooting

### Common Issues

1. **"Module not found"**: Ensure you're running Terraform from the environment directory
2. **"Backend not configured"**: Run `terraform init` in the environment directory
3. **"Resource conflicts"**: Each environment uses different resource names and networks

### Getting Help

1. **Check Documentation**: README.md has comprehensive setup instructions
2. **Migration Issues**: See MIGRATION.md for migration-specific guidance
3. **Validate Configuration**: Use `terraform validate` and `terraform fmt`

## Next Steps

1. **Deploy Foundation**: Start with one environment to test the setup
2. **Add Service Modules**: Create modules for compute, storage, networking
3. **Implement CI/CD**: Automate deployments across environments
4. **Add Monitoring**: Implement comprehensive monitoring and alerting
5. **Security Hardening**: Add security best practices and compliance checks