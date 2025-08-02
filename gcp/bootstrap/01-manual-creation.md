# Approach 1: Manual Bucket Creation

**Best for**: Learning, small teams, quick setup
**Complexity**: Low
**Time**: 5 minutes

## Overview

Create the state bucket manually using gcloud CLI, then configure Terraform to use it.

## Steps

### 1. Create State Bucket Manually

```bash
# Set your project and environment
export PROJECT_ID="your-gcp-project-id"
export ENVIRONMENT="dev"  # or stg, prd
export BUCKET_NAME="${PROJECT_ID}-terraform-state-${ENVIRONMENT}"

# Create the bucket
gsutil mb -p ${PROJECT_ID} -c STANDARD -l us-central1 gs://${BUCKET_NAME}

# Enable versioning (important for state safety)
gsutil versioning set on gs://${BUCKET_NAME}

# Set lifecycle policy to clean up old versions
cat > lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "age": 30,
          "isLive": false
        }
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://${BUCKET_NAME}
rm lifecycle.json
```

### 2. Update Environment Backend Configuration

Edit your environment's `terraform.tf` file:

```hcl
# In environments/dev/terraform.tf (or stg/prd)
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "your-project-id-terraform-state-dev"  # Replace with your bucket
    prefix = "terraform/state"
  }
}
```

### 3. Migrate Existing State (if any)

```bash
cd environments/dev  # or your target environment

# Initialize with new backend
terraform init

# If you have existing local state, Terraform will ask to migrate it
# Answer "yes" when prompted
```

## Pros
- ✅ Simple and fast
- ✅ No additional tools required
- ✅ Works immediately

## Cons
- ❌ Manual process (not Infrastructure as Code)
- ❌ Not version controlled
- ❌ Need to repeat for each environment
- ❌ No automated security settings

## Security Considerations

```bash
# Optional: Restrict bucket access
gsutil iam ch -d allUsers:objectViewer gs://${BUCKET_NAME}
gsutil iam ch user:your-email@domain.com:objectAdmin gs://${BUCKET_NAME}
```