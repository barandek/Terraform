#!/bin/bash

# Debug Permissions Script
# This script helps debug permission issues with GCP bootstrap

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
PROJECT_ID=""

# Function to show usage
show_usage() {
    echo "Usage: $0 -p PROJECT_ID"
    echo ""
    echo "Options:"
    echo "  -p PROJECT_ID    GCP Project ID (required)"
    echo "  -h               Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -p my-gcp-project"
}

# Parse command line arguments
while getopts "p:h" opt; do
    case $opt in
        p) PROJECT_ID="$OPTARG" ;;
        h) show_usage; exit 0 ;;
        *) show_usage; exit 1 ;;
    esac
done

# Validate required parameters
if [[ -z "$PROJECT_ID" ]]; then
    print_error "Missing required parameter: PROJECT_ID"
    show_usage
    exit 1
fi

print_status "Debug information for project: $PROJECT_ID"
echo ""

# 1. Check gcloud configuration
print_status "=== gcloud Configuration ==="
print_status "gcloud version:"
gcloud version 2>/dev/null || print_error "gcloud not found"
echo ""

print_status "Active account:"
gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || print_error "No active account"
echo ""

print_status "Current project:"
gcloud config get-value project 2>/dev/null || print_error "No project set"
echo ""

# 2. Test basic project access
print_status "=== Basic Project Access ==="
print_status "Testing project access..."
if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
    print_success "Can access project: $PROJECT_ID"
    
    # Get project details
    print_status "Project details:"
    gcloud projects describe "$PROJECT_ID" --format="table(projectId,name,lifecycleState)" 2>/dev/null
else
    print_error "Cannot access project: $PROJECT_ID"
    print_status "Available projects:"
    gcloud projects list --format="table(projectId,name)" 2>/dev/null | head -10
fi
echo ""

# 3. Check API status
print_status "=== API Status ==="
print_status "Checking required APIs..."

apis=(
    "storage.googleapis.com:Cloud Storage"
    "cloudresourcemanager.googleapis.com:Cloud Resource Manager"
    "serviceusage.googleapis.com:Service Usage"
)

for api_info in "${apis[@]}"; do
    api=$(echo "$api_info" | cut -d: -f1)
    name=$(echo "$api_info" | cut -d: -f2)
    
    if gcloud services list --enabled --filter="name:$api" --format="value(name)" 2>/dev/null | grep -q "$api"; then
        print_success "$name API is enabled"
    else
        print_warning "$name API is not enabled"
    fi
done
echo ""

# 4. Test IAM permission checking capability
print_status "=== IAM Permission Testing ==="
print_status "Testing if IAM permission checking works..."

test_permission="resourcemanager.projects.get"
result=$(gcloud projects test-iam-permissions "$PROJECT_ID" --permissions="$test_permission" --format="value(permissions)" 2>&1)
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    if [[ "$result" == "$test_permission" ]]; then
        print_success "IAM permission testing works - you have basic project access"
    else
        print_warning "IAM permission testing works but you may have limited permissions"
        print_status "Result: $result"
    fi
else
    print_error "IAM permission testing failed"
    print_status "Error output: $result"
    
    # Common error analysis
    if echo "$result" | grep -q "API.*not enabled"; then
        print_status "Likely cause: Cloud Resource Manager API not enabled"
        print_status "Solution: Enable the API manually in Cloud Console"
    elif echo "$result" | grep -q "permission denied\|access denied"; then
        print_status "Likely cause: Insufficient permissions"
        print_status "Solution: Request basic project access from administrator"
    fi
fi
echo ""

# 5. Test storage access
print_status "=== Storage Access ==="
print_status "Testing basic storage access..."

if gsutil ls -p "$PROJECT_ID" &> /dev/null; then
    print_success "Can access Cloud Storage"
    
    # Count existing buckets
    bucket_count=$(gsutil ls -p "$PROJECT_ID" 2>/dev/null | wc -l)
    print_status "Existing buckets in project: $bucket_count"
else
    print_error "Cannot access Cloud Storage"
    print_status "This could indicate:"
    print_status "  - Cloud Storage API not enabled"
    print_status "  - No storage permissions"
    print_status "  - Project billing not enabled"
fi
echo ""

# 6. Test bucket creation (if user confirms)
print_status "=== Bucket Creation Test ==="
read -p "Do you want to test bucket creation? This will create and delete a test bucket. (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    test_bucket="debug-test-$(date +%s)-${RANDOM}"
    print_status "Testing bucket creation with name: $test_bucket"
    
    if gsutil mb -p "$PROJECT_ID" -c STANDARD -l us-central1 "gs://$test_bucket" 2>/dev/null; then
        print_success "Successfully created test bucket"
        
        # Test writing to bucket
        if echo "test" | gsutil cp - "gs://$test_bucket/test.txt" 2>/dev/null; then
            print_success "Successfully wrote to test bucket"
            
            # Clean up
            if gsutil rm -r "gs://$test_bucket" 2>/dev/null; then
                print_success "Successfully cleaned up test bucket"
            else
                print_warning "Could not clean up test bucket: gs://$test_bucket"
            fi
        else
            print_error "Could not write to test bucket"
            gsutil rm -r "gs://$test_bucket" 2>/dev/null || true
        fi
    else
        print_error "Could not create test bucket"
        print_status "This indicates missing storage.buckets.create permission"
    fi
else
    print_status "Skipping bucket creation test"
fi
echo ""

# 7. Show current IAM roles
print_status "=== Current IAM Roles ==="
print_status "Your current roles in this project:"

current_user=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)
if [[ -n "$current_user" ]]; then
    print_status "Checking roles for: $current_user"
    
    if gcloud projects get-iam-policy "$PROJECT_ID" --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:$current_user" 2>/dev/null; then
        print_success "Successfully retrieved your roles"
    else
        print_warning "Could not retrieve your roles (this may be normal)"
    fi
else
    print_error "Could not determine current user"
fi
echo ""

# 8. Recommendations
print_status "=== Recommendations ==="
print_status "Based on the tests above, here are recommendations:"
echo ""

print_status "If you saw errors:"
print_status "  1. Enable required APIs in Cloud Console:"
print_status "     - Cloud Storage API"
print_status "     - Cloud Resource Manager API"
print_status "     - Service Usage API"
echo ""
print_status "  2. Request these IAM roles from your project administrator:"
print_status "     - roles/storage.admin (for bucket management)"
print_status "     - roles/serviceusage.serviceUsageAdmin (for API management)"
echo ""
print_status "  3. Verify billing is enabled for the project"
echo ""

print_status "If everything worked:"
print_status "  - You should be able to run the bootstrap script successfully"
print_status "  - Run: ./02-bootstrap-script.sh -p $PROJECT_ID -e dev"
echo ""

print_status "For more help, see PRIVILEGE-REQUIREMENTS.md"