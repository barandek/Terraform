#!/bin/bash

# Test Bootstrap Setup
# This script validates that the bootstrap process completed successfully

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
ENVIRONMENT=""

# Function to show usage
show_usage() {
    echo "Usage: $0 -p PROJECT_ID -e ENVIRONMENT"
    echo ""
    echo "Options:"
    echo "  -p PROJECT_ID    GCP Project ID (required)"
    echo "  -e ENVIRONMENT   Environment (dev/stg/prd) (required)"
    echo "  -h               Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -p my-gcp-project -e dev"
}

# Parse command line arguments
while getopts "p:e:h" opt; do
    case $opt in
        p) PROJECT_ID="$OPTARG" ;;
        e) ENVIRONMENT="$OPTARG" ;;
        h) show_usage; exit 0 ;;
        *) show_usage; exit 1 ;;
    esac
done

# Validate required parameters
if [[ -z "$PROJECT_ID" || -z "$ENVIRONMENT" ]]; then
    print_error "Missing required parameters"
    show_usage
    exit 1
fi

BUCKET_NAME="${PROJECT_ID}-terraform-state-${ENVIRONMENT}"
TESTS_PASSED=0
TESTS_FAILED=0

print_status "Testing bootstrap setup for:"
print_status "  Project: $PROJECT_ID"
print_status "  Environment: $ENVIRONMENT"
print_status "  Bucket: $BUCKET_NAME"
echo ""

# Test 1: Check if bucket exists
print_status "Test 1: Checking if state bucket exists..."
if gsutil ls -b gs://"$BUCKET_NAME" &> /dev/null; then
    print_success "State bucket exists: gs://$BUCKET_NAME"
    ((TESTS_PASSED++))
else
    print_error "State bucket does not exist: gs://$BUCKET_NAME"
    ((TESTS_FAILED++))
fi

# Test 2: Check bucket versioning
print_status "Test 2: Checking bucket versioning..."
versioning_status=$(gsutil versioning get gs://"$BUCKET_NAME" 2>/dev/null | grep -o "Enabled\|Suspended" || echo "Unknown")
if [[ "$versioning_status" == "Enabled" ]]; then
    print_success "Bucket versioning is enabled"
    ((TESTS_PASSED++))
else
    print_error "Bucket versioning is not enabled (status: $versioning_status)"
    ((TESTS_FAILED++))
fi

# Test 3: Check lifecycle policy
print_status "Test 3: Checking lifecycle policy..."
if gsutil lifecycle get gs://"$BUCKET_NAME" &> /dev/null; then
    print_success "Lifecycle policy is configured"
    ((TESTS_PASSED++))
else
    print_warning "No lifecycle policy found (optional but recommended)"
fi

# Test 4: Test write permissions
print_status "Test 4: Testing write permissions..."
test_file="test-$(date +%s).txt"
if echo "test content" | gsutil cp - gs://"$BUCKET_NAME"/"$test_file" &> /dev/null; then
    print_success "Can write to bucket"
    ((TESTS_PASSED++))
    
    # Clean up test file
    gsutil rm gs://"$BUCKET_NAME"/"$test_file" &> /dev/null || true
else
    print_error "Cannot write to bucket"
    ((TESTS_FAILED++))
fi

# Test 5: Check bucket location
print_status "Test 5: Checking bucket location..."
bucket_location=$(gsutil ls -L -b gs://"$BUCKET_NAME" | grep "Location constraint:" | awk '{print $3}')
if [[ -n "$bucket_location" ]]; then
    print_success "Bucket location: $bucket_location"
    ((TESTS_PASSED++))
else
    print_warning "Could not determine bucket location"
fi

# Test 6: Check if backend configuration files exist
print_status "Test 6: Checking for backend configuration files..."
config_files=(
    "backend-${ENVIRONMENT}.hcl"
    "terraform-backend-${ENVIRONMENT}.tf"
    "migrate-to-remote-${ENVIRONMENT}.sh"
)

for file in "${config_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "Configuration file exists: $file"
        ((TESTS_PASSED++))
    else
        print_warning "Configuration file missing: $file"
    fi
done

# Test 7: Validate Terraform backend configuration
print_status "Test 7: Validating Terraform backend configuration..."
if [[ -f "terraform-backend-${ENVIRONMENT}.tf" ]]; then
    if grep -q "bucket.*=.*\"$BUCKET_NAME\"" "terraform-backend-${ENVIRONMENT}.tf"; then
        print_success "Backend configuration has correct bucket name"
        ((TESTS_PASSED++))
    else
        print_error "Backend configuration has incorrect bucket name"
        ((TESTS_FAILED++))
    fi
else
    print_warning "Backend configuration file not found"
fi

# Test 8: Test Terraform initialization (if in environment directory)
if [[ -f "../environments/${ENVIRONMENT}/terraform.tf" ]]; then
    print_status "Test 8: Testing Terraform initialization..."
    cd "../environments/${ENVIRONMENT}"
    
    if terraform init -backend=false &> /dev/null; then
        print_success "Terraform configuration is valid"
        ((TESTS_PASSED++))
    else
        print_error "Terraform configuration has errors"
        ((TESTS_FAILED++))
    fi
    
    cd - > /dev/null
else
    print_warning "Environment directory not found, skipping Terraform test"
fi

echo ""
print_status "=== Test Summary ==="
print_success "Tests passed: $TESTS_PASSED"
if [[ $TESTS_FAILED -gt 0 ]]; then
    print_error "Tests failed: $TESTS_FAILED"
fi

echo ""
if [[ $TESTS_FAILED -eq 0 ]]; then
    print_success "✅ Bootstrap setup is working correctly!"
    echo ""
    print_status "Next steps:"
    print_status "  1. Update your environment's terraform.tf with the backend configuration"
    print_status "  2. Run 'terraform init' in your environment directory"
    print_status "  3. Terraform will prompt to migrate existing state (if any)"
    echo ""
    print_status "Backend configuration:"
    print_status "  Bucket: gs://$BUCKET_NAME"
    print_status "  Prefix: terraform/state"
else
    print_error "❌ Bootstrap setup has issues that need to be fixed"
    echo ""
    print_status "Common solutions:"
    print_status "  - Re-run the bootstrap script: ./02-bootstrap-script.sh"
    print_status "  - Check permissions: ./verify-privileges.sh -p $PROJECT_ID"
    print_status "  - Verify bucket manually: gsutil ls -L -b gs://$BUCKET_NAME"
fi

exit $TESTS_FAILED