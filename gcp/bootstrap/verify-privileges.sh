#!/bin/bash

# GCP Bootstrap Privilege Verification Script
# This script verifies that the current user has all necessary permissions
# to run the bootstrap process for Terraform state management

# Note: Not using 'set -e' to allow graceful error handling

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

# Debug function to show progress
debug_step() {
    echo "[DEBUG] $1" >&2
}

# Configuration
PROJECT_ID=""
CHECK_BILLING=false
VERBOSE=false

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Function to show usage
show_usage() {
    echo "Usage: $0 -p PROJECT_ID [-b] [-v] [-h]"
    echo ""
    echo "Options:"
    echo "  -p PROJECT_ID    GCP Project ID (required)"
    echo "  -b               Check billing account permissions (optional)"
    echo "  -v               Verbose output"
    echo "  -h               Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -p my-gcp-project"
    echo "  $0 -p my-gcp-project -b -v"
}

# Parse command line arguments
while getopts "p:bvh" opt; do
    case $opt in
        p) PROJECT_ID="$OPTARG" ;;
        b) CHECK_BILLING=true ;;
        v) VERBOSE=true ;;
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

verbose_log() {
    if [[ "$VERBOSE" == true ]]; then
        print_status "$1"
    fi
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    local description="$2"
    
    debug_step "Checking if command '$cmd' exists"
    
    if command -v "$cmd" &> /dev/null; then
        print_success "$description is installed"
        ((CHECKS_PASSED++))
        debug_step "Command '$cmd' found"
        return 0
    else
        print_error "$description is not installed"
        ((CHECKS_FAILED++))
        debug_step "Command '$cmd' not found"
        return 1
    fi
}

# Function to check gcloud authentication
check_gcloud_auth() {
    debug_step "Running gcloud auth list command"
    local active_account
    active_account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)
    debug_step "gcloud auth list completed"
    
    if [[ -n "$active_account" ]]; then
        print_success "Authenticated as: $active_account"
        ((CHECKS_PASSED++))
        return 0
    else
        print_error "Not authenticated with gcloud. Run: gcloud auth login"
        ((CHECKS_FAILED++))
        return 1
    fi
}

# Function to check project access
check_project_access() {
    verbose_log "Checking project access for: $PROJECT_ID"
    
    if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
        print_success "Can access project: $PROJECT_ID"
        ((CHECKS_PASSED++))
        return 0
    else
        print_error "Cannot access project: $PROJECT_ID"
        print_error "  - Project may not exist"
        print_error "  - You may not have access"
        print_error "  - Check project ID spelling"
        ((CHECKS_FAILED++))
        return 1
    fi
}

# Function to check specific IAM permission
check_iam_permission() {
    local permission="$1"
    local description="$2"
    
    verbose_log "Checking permission: $permission"
    
    # First check if the project is accessible
    if ! gcloud projects describe "$PROJECT_ID" &> /dev/null; then
        print_error "$description - Cannot access project"
        ((CHECKS_FAILED++))
        return 1
    fi
    
    local result
    local error_output
    
    # Capture both stdout and stderr
    result=$(gcloud projects test-iam-permissions "$PROJECT_ID" --permissions="$permission" --format="value(permissions)" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 && "$result" == "$permission" ]]; then
        print_success "$description"
        ((CHECKS_PASSED++))
        return 0
    else
        # Check for common error patterns
        if echo "$result" | grep -q "does not exist\|not found\|invalid"; then
            print_error "$description - Project or permission not found"
            print_error "  Error: $result"
        elif echo "$result" | grep -q "permission denied\|access denied"; then
            print_error "$description - Access denied"
            print_error "  Missing permission: $permission"
        elif echo "$result" | grep -q "API.*not enabled"; then
            print_warning "$description - API not enabled (will try to enable)"
            ((CHECKS_WARNING++))
            return 0
        else
            print_error "$description"
            print_error "  Missing permission: $permission"
            if [[ "$VERBOSE" == true ]]; then
                print_error "  Debug output: $result"
            fi
        fi
        ((CHECKS_FAILED++))
        return 1
    fi
}

# Function to check API enablement permissions
check_api_permissions() {
    print_status "Checking API management permissions..."
    
    # Check if we can list services first (basic requirement)
    if gcloud services list --enabled --limit=1 &> /dev/null; then
        print_success "Can list enabled services"
        ((CHECKS_PASSED++))
    else
        print_error "Cannot list enabled services"
        print_error "  This may indicate missing basic project access"
        ((CHECKS_FAILED++))
        return 1
    fi
    
    # Check API management permissions
    check_iam_permission "serviceusage.services.enable" "Can enable APIs"
    check_iam_permission "serviceusage.services.list" "Can list APIs"
    
    # Check if required APIs are already enabled
    verbose_log "Checking if required APIs are enabled..."
    
    # Check Cloud Storage API
    local storage_enabled
    storage_enabled=$(gcloud services list --enabled --filter="name:storage.googleapis.com" --format="value(name)" 2>/dev/null)
    
    if [[ -n "$storage_enabled" ]]; then
        print_success "Cloud Storage API is enabled"
        ((CHECKS_PASSED++))
    else
        print_warning "Cloud Storage API is not enabled (will be enabled during bootstrap)"
        ((CHECKS_WARNING++))
    fi
    
    # Check Cloud Resource Manager API
    local crm_enabled
    crm_enabled=$(gcloud services list --enabled --filter="name:cloudresourcemanager.googleapis.com" --format="value(name)" 2>/dev/null)
    
    if [[ -n "$crm_enabled" ]]; then
        print_success "Cloud Resource Manager API is enabled"
        ((CHECKS_PASSED++))
    else
        print_warning "Cloud Resource Manager API is not enabled (will be enabled during bootstrap)"
        ((CHECKS_WARNING++))
    fi
    
    # Check Service Usage API (needed for enabling other APIs)
    local serviceusage_enabled
    serviceusage_enabled=$(gcloud services list --enabled --filter="name:serviceusage.googleapis.com" --format="value(name)" 2>/dev/null)
    
    if [[ -n "$serviceusage_enabled" ]]; then
        print_success "Service Usage API is enabled"
        ((CHECKS_PASSED++))
    else
        print_warning "Service Usage API is not enabled (may need manual enablement)"
        ((CHECKS_WARNING++))
    fi
}

# Function to check storage permissions
check_storage_permissions() {
    print_status "Checking Cloud Storage permissions..."
    
    # Try to check permissions via IAM API
    local iam_check_failed=false
    
    if ! check_iam_permission "storage.buckets.create" "Can create storage buckets"; then
        iam_check_failed=true
    fi
    
    check_iam_permission "storage.buckets.get" "Can read storage bucket metadata"
    check_iam_permission "storage.buckets.update" "Can update storage bucket configuration"
    check_iam_permission "storage.objects.create" "Can create storage objects"
    check_iam_permission "storage.objects.delete" "Can delete storage objects"
    check_iam_permission "storage.objects.get" "Can read storage objects"
    check_iam_permission "storage.objects.list" "Can list storage objects"
    
    # If IAM permission checking failed, try a practical test
    if [[ "$iam_check_failed" == true ]]; then
        print_status "IAM permission check failed, trying practical storage test..."
        
        # Try to list existing buckets as a basic test
        if gsutil ls -p "$PROJECT_ID" &> /dev/null; then
            print_success "Can access Cloud Storage (practical test)"
            ((CHECKS_PASSED++))
        else
            print_error "Cannot access Cloud Storage (practical test failed)"
            ((CHECKS_FAILED++))
        fi
    fi
}

# Function to check IAM permissions
check_iam_permissions() {
    print_status "Checking IAM permissions..."
    
    # Basic project access (we already checked this, but verify again)
    if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
        print_success "Can read project information (verified)"
        ((CHECKS_PASSED++))
    else
        print_error "Cannot read project information"
        ((CHECKS_FAILED++))
        return 1
    fi
    
    # Try to check IAM policy reading permission
    check_iam_permission "resourcemanager.projects.getIamPolicy" "Can read project IAM policy"
    
    # Optional: Check if user can modify IAM (needed for advanced security)
    verbose_log "Checking optional IAM modification permission..."
    local iam_result
    iam_result=$(gcloud projects test-iam-permissions "$PROJECT_ID" --permissions="resourcemanager.projects.setIamPolicy" --format="value(permissions)" 2>/dev/null)
    
    if [[ "$iam_result" == "resourcemanager.projects.setIamPolicy" ]]; then
        print_success "Can modify project IAM policies (recommended for security)"
        ((CHECKS_PASSED++))
    else
        print_warning "Cannot modify project IAM policies (bucket security will be limited)"
        print_warning "  This is optional - bootstrap will still work"
        ((CHECKS_WARNING++))
    fi
}

# Function to check billing permissions (optional)
check_billing_permissions() {
    if [[ "$CHECK_BILLING" != true ]]; then
        return 0
    fi
    
    print_status "Checking billing permissions..."
    
    # Get billing account for project
    local billing_account
    billing_account=$(gcloud beta billing projects describe "$PROJECT_ID" --format="value(billingAccountName)" 2>/dev/null | sed 's|billingAccounts/||')
    
    if [[ -n "$billing_account" ]]; then
        print_success "Project has billing account: $billing_account"
        ((CHECKS_PASSED++))
        
        # Check billing permissions
        local billing_result
        billing_result=$(gcloud beta billing accounts test-iam-permissions "$billing_account" --permissions="billing.accounts.get" --format="value(permissions)" 2>/dev/null)
        
        if [[ "$billing_result" == "billing.accounts.get" ]]; then
            print_success "Can access billing account information"
            ((CHECKS_PASSED++))
        else
            print_warning "Cannot access billing account (may affect cost monitoring)"
            ((CHECKS_WARNING++))
        fi
    else
        print_warning "No billing account associated with project"
        ((CHECKS_WARNING++))
    fi
}

# Function to check terraform binary
check_terraform() {
    if check_command "terraform" "Terraform CLI"; then
        local tf_version
        # Try different methods to get terraform version
        tf_version=$(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
        
        if [[ -z "$tf_version" ]]; then
            # Fallback to simple version command
            tf_version=$(terraform version 2>/dev/null | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/v//')
        fi
        
        if [[ -n "$tf_version" ]]; then
            verbose_log "Terraform version: $tf_version"
            
            # Check if version is >= 1.0
            local major_version
            major_version=$(echo "$tf_version" | cut -d. -f1)
            
            if [[ "$major_version" -ge 1 ]] 2>/dev/null; then
                print_success "Terraform version is compatible (>= 1.0): $tf_version"
                ((CHECKS_PASSED++))
            else
                print_warning "Terraform version may be too old (< 1.0): $tf_version"
                ((CHECKS_WARNING++))
            fi
        else
            print_warning "Could not determine Terraform version"
            ((CHECKS_WARNING++))
        fi
    else
        print_warning "Terraform not found - this is optional for bootstrap"
    fi
}

# Function to test bucket creation (dry run)
test_bucket_creation() {
    print_status "Testing bucket creation permissions..."
    
    local test_bucket="test-permissions-$(date +%s)-${RANDOM}"
    
    verbose_log "Testing with bucket name: $test_bucket"
    
    # Try to create a test bucket
    if gsutil mb -p "$PROJECT_ID" -c STANDARD -l us-central1 "gs://$test_bucket" &> /dev/null; then
        print_success "Can create storage buckets (verified)"
        
        # Clean up test bucket
        if gsutil rm -r "gs://$test_bucket" &> /dev/null; then
            verbose_log "Test bucket cleaned up successfully"
        else
            print_warning "Could not clean up test bucket: gs://$test_bucket"
        fi
        
        ((CHECKS_PASSED++))
        return 0
    else
        print_error "Cannot create storage buckets (test failed)"
        ((CHECKS_FAILED++))
        return 1
    fi
}

# Function to check existing state buckets
check_existing_buckets() {
    print_status "Checking for existing state buckets..."
    
    local bucket_patterns=(
        "${PROJECT_ID}-terraform-state-dev"
        "${PROJECT_ID}-terraform-state-stg"
        "${PROJECT_ID}-terraform-state-prd"
    )
    
    for bucket in "${bucket_patterns[@]}"; do
        if gsutil ls -b "gs://$bucket" &> /dev/null; then
            print_warning "Bucket already exists: gs://$bucket"
            ((CHECKS_WARNING++))
        else
            verbose_log "Bucket available: gs://$bucket"
        fi
    done
}

# Main execution
main() {
    print_status "GCP Bootstrap Privilege Verification"
    print_status "Project: $PROJECT_ID"
    echo ""
    
    # Debug: Show script progress
    verbose_log "Starting verification process..."
    
    # Basic tool checks
    print_status "=== Tool Installation Checks ==="
    debug_step "Starting tool checks"
    
    # Check gcloud (critical)
    debug_step "Checking gcloud command"
    if ! check_command "gcloud" "Google Cloud CLI"; then
        print_error "gcloud CLI is required for bootstrap."
        print_status "Installation guide: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check gsutil (usually comes with gcloud)
    debug_step "Checking gsutil command"
    check_command "gsutil" "Google Cloud Storage utility" || true
    
    # Check terraform (optional for bootstrap)
    debug_step "Checking terraform command"
    check_terraform || true
    
    echo ""
    debug_step "Tool checks completed"
    verbose_log "Tool checks completed. Moving to authentication checks..."
    
    # Authentication checks
    print_status "=== Authentication Checks ==="
    debug_step "Starting authentication checks"
    
    verbose_log "Checking gcloud authentication..."
    debug_step "About to check gcloud auth"
    if ! check_gcloud_auth; then
        print_error "Authentication failed. Cannot proceed with further checks."
        exit 1
    fi
    
    verbose_log "Checking project access..."
    debug_step "About to check project access"
    if ! check_project_access; then
        print_error "Project access failed. Cannot proceed with further checks."
        exit 1
    fi
    
    echo ""
    debug_step "Authentication checks completed"
    
    # Permission checks (only if basic access works)
    print_status "=== Permission Checks ==="
    
    # Check if we can run permission tests at all
    if gcloud projects test-iam-permissions "$PROJECT_ID" --permissions="resourcemanager.projects.get" &> /dev/null; then
        verbose_log "IAM permission testing is available"
        
        check_api_permissions
        echo ""
        check_storage_permissions
        echo ""
        check_iam_permissions
        echo ""
    else
        print_warning "IAM permission testing is not available"
        print_warning "This could be due to:"
        print_warning "  - Cloud Resource Manager API not enabled"
        print_warning "  - Insufficient permissions for permission testing"
        print_warning "  - Project configuration issues"
        print_status "Skipping detailed permission checks, will rely on practical tests"
        ((CHECKS_WARNING++))
        echo ""
    fi
    
    # Optional billing check
    if [[ "$CHECK_BILLING" == true ]]; then
        check_billing_permissions
        echo ""
    fi
    
    # Practical tests
    print_status "=== Practical Tests ==="
    test_bucket_creation
    check_existing_buckets
    echo ""
    
    # Summary
    print_status "=== Summary ==="
    print_success "Checks passed: $CHECKS_PASSED"
    if [[ $CHECKS_WARNING -gt 0 ]]; then
        print_warning "Warnings: $CHECKS_WARNING"
    fi
    if [[ $CHECKS_FAILED -gt 0 ]]; then
        print_error "Checks failed: $CHECKS_FAILED"
    fi
    echo ""
    
    # Final recommendation
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        print_success "✅ All critical checks passed! You can proceed with bootstrap."
        if [[ $CHECKS_WARNING -gt 0 ]]; then
            print_warning "⚠️  Some warnings were found. Review them before proceeding."
        fi
        exit 0
    else
        print_error "❌ Some critical checks failed. Fix the issues before running bootstrap."
        echo ""
        print_status "Common solutions:"
        print_status "  - Run: gcloud auth login"
        print_status "  - Check project ID: gcloud projects list"
        print_status "  - Request necessary IAM roles from project admin"
        print_status "  - Enable required APIs manually in Cloud Console"
        exit 1
    fi
}

# Run main function
main