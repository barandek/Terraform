# GCP Bootstrap Privilege Requirements

This document outlines the minimum permissions required to successfully run the Terraform state bootstrap process for GCP.

## Quick Verification

Run the privilege verification script to check all requirements:

```bash
# Basic check
./verify-privileges.sh -p YOUR_PROJECT_ID

# Comprehensive check with billing
./verify-privileges.sh -p YOUR_PROJECT_ID -b -v
```

## Required Tools

### 1. Google Cloud CLI (gcloud)
```bash
# Install gcloud CLI
# https://cloud.google.com/sdk/docs/install

# Verify installation
gcloud --version

# Authenticate
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID
```

### 2. Terraform
```bash
# Install Terraform >= 1.0
# https://developer.hashicorp.com/terraform/downloads

# Verify installation
terraform version
```

## Required GCP Permissions

### Core Project Permissions

| Permission | Purpose | Required For |
|------------|---------|--------------|
| `resourcemanager.projects.get` | Read project information | All operations |
| `resourcemanager.projects.getIamPolicy` | Read project IAM policy | Security checks |
| `resourcemanager.projects.setIamPolicy` | Modify project IAM policy | Bucket security (optional) |

### API Management Permissions

| Permission | Purpose | Required For |
|------------|---------|--------------|
| `serviceusage.services.enable` | Enable GCP APIs | Bootstrap script |
| `serviceusage.services.list` | List enabled APIs | Verification |

### Cloud Storage Permissions

| Permission | Purpose | Required For |
|------------|---------|--------------|
| `storage.buckets.create` | Create storage buckets | State bucket creation |
| `storage.buckets.get` | Read bucket metadata | Bucket configuration |
| `storage.buckets.update` | Update bucket settings | Versioning, lifecycle |
| `storage.buckets.getIamPolicy` | Read bucket IAM | Security configuration |
| `storage.buckets.setIamPolicy` | Set bucket IAM | Security configuration |
| `storage.objects.create` | Upload objects | Terraform state files |
| `storage.objects.delete` | Delete objects | State cleanup |
| `storage.objects.get` | Download objects | State retrieval |
| `storage.objects.list` | List objects | State management |

### Optional Billing Permissions

| Permission | Purpose | Required For |
|------------|---------|--------------|
| `billing.accounts.get` | Read billing account info | Cost monitoring |
| `billing.resourceAssociations.list` | List billing associations | Budget setup |

## Recommended IAM Roles

Instead of individual permissions, you can use these predefined roles:

### Minimum Required Roles
```bash
# For basic bootstrap functionality
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="user:YOUR_EMAIL" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="user:YOUR_EMAIL" \
    --role="roles/serviceusage.serviceUsageAdmin"
```

### Recommended Roles for Full Functionality
```bash
# Storage Admin - Full storage permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="user:YOUR_EMAIL" \
    --role="roles/storage.admin"

# Service Usage Admin - API management
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="user:YOUR_EMAIL" \
    --role="roles/serviceusage.serviceUsageAdmin"

# Project IAM Admin - Security configuration
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="user:YOUR_EMAIL" \
    --role="roles/resourcemanager.projectIamAdmin"
```

### Enterprise/Production Roles
```bash
# Project Editor - Comprehensive permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="user:YOUR_EMAIL" \
    --role="roles/editor"

# Or Project Owner - Full permissions (use carefully)
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="user:YOUR_EMAIL" \
    --role="roles/owner"
```

## Required APIs

The following APIs must be enabled in your project:

```bash
# Enable required APIs
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Verify APIs are enabled
gcloud services list --enabled --filter="name:(storage.googleapis.com OR cloudresourcemanager.googleapis.com)"
```

## Common Permission Issues

### Issue: "Permission denied" when creating buckets

**Symptoms:**
```
ERROR: (gcloud.storage.buckets.create) User does not have permission to access project
```

**Solutions:**
1. Verify project access: `gcloud projects describe YOUR_PROJECT_ID`
2. Check storage permissions: `gcloud projects test-iam-permissions YOUR_PROJECT_ID --permissions=storage.buckets.create`
3. Request `roles/storage.admin` role from project administrator

### Issue: "API not enabled" errors

**Symptoms:**
```
ERROR: (gcloud.services.enable) The request cannot be identified with a project
```

**Solutions:**
1. Enable APIs manually in Cloud Console
2. Request `roles/serviceusage.serviceUsageAdmin` role
3. Use `gcloud services enable` command

### Issue: "Access denied" for IAM operations

**Symptoms:**
```
ERROR: (gcloud.projects.set-iam-policy) User does not have permission to access project
```

**Solutions:**
1. This is optional for basic bootstrap
2. Request `roles/resourcemanager.projectIamAdmin` for full security features
3. Skip IAM modifications if not available

## Security Best Practices

### 1. Principle of Least Privilege
- Start with minimum required roles
- Add additional permissions only when needed
- Use custom roles for fine-grained control

### 2. Service Account Usage (Recommended for CI/CD)
```bash
# Create service account for automation
gcloud iam service-accounts create terraform-bootstrap \
    --display-name="Terraform Bootstrap Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-bootstrap@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Create and download key
gcloud iam service-accounts keys create terraform-bootstrap-key.json \
    --iam-account=terraform-bootstrap@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Use service account
export GOOGLE_APPLICATION_CREDENTIALS="./terraform-bootstrap-key.json"
```

### 3. Temporary Permissions
- Request elevated permissions temporarily
- Remove permissions after bootstrap completion
- Use time-bound IAM conditions when possible

## Troubleshooting Commands

### Check Current Permissions
```bash
# List your current roles
gcloud projects get-iam-policy YOUR_PROJECT_ID \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" \
    --filter="bindings.members:YOUR_EMAIL"

# Test specific permissions
gcloud projects test-iam-permissions YOUR_PROJECT_ID \
    --permissions=storage.buckets.create,storage.objects.create
```

### Verify API Status
```bash
# List all enabled APIs
gcloud services list --enabled

# Check specific API
gcloud services list --enabled --filter="name:storage.googleapis.com"
```

### Debug Authentication
```bash
# Check current authentication
gcloud auth list

# Check current project
gcloud config get-value project

# Verify project access
gcloud projects describe YOUR_PROJECT_ID
```

## Verification Script Usage

The `verify-privileges.sh` script performs comprehensive checks:

```bash
# Basic verification
./verify-privileges.sh -p YOUR_PROJECT_ID

# Verbose output with billing checks
./verify-privileges.sh -p YOUR_PROJECT_ID -b -v

# Help
./verify-privileges.sh -h
```

### Script Output Interpretation

- ✅ **Green (SUCCESS)**: Requirement met, no action needed
- ⚠️ **Yellow (WARNING)**: Non-critical issue, bootstrap may work but with limitations
- ❌ **Red (ERROR)**: Critical issue, must be fixed before bootstrap

### Example Output
```
[SUCCESS] Authenticated as: user@example.com
[SUCCESS] Can access project: my-project-123
[SUCCESS] Can create storage buckets
[WARNING] Cloud Storage API is not enabled (will be enabled during bootstrap)
[ERROR] Missing permission: storage.buckets.create
```

## Next Steps

1. Run the verification script: `./verify-privileges.sh -p YOUR_PROJECT_ID`
2. Fix any critical errors identified
3. Proceed with bootstrap using your preferred method:
   - Manual creation: `01-manual-creation.md`
   - Bootstrap script: `./02-bootstrap-script.sh`
   - Bootstrap module: `03-bootstrap-module/`

## Support

If you encounter permission issues:

1. Check this document for common solutions
2. Run the verification script with `-v` flag for detailed output
3. Contact your GCP project administrator for role assignments
4. Review GCP IAM documentation: https://cloud.google.com/iam/docs