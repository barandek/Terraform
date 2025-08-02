#!/bin/bash

# Minimal verification script for debugging

PROJECT_ID="$1"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 PROJECT_ID"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_status "Minimal GCP Bootstrap Verification"
print_status "Project: $PROJECT_ID"
echo ""

print_status "Step 1: Checking gcloud command..."
if command -v gcloud &> /dev/null; then
    print_success "gcloud command found"
else
    print_error "gcloud command not found"
    exit 1
fi

print_status "Step 2: Checking gcloud version..."
if gcloud version &> /dev/null; then
    print_success "gcloud version check passed"
else
    print_error "gcloud version check failed"
fi

print_status "Step 3: Checking authentication..."
active_account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)
if [[ -n "$active_account" ]]; then
    print_success "Authenticated as: $active_account"
else
    print_error "Not authenticated with gcloud"
    exit 1
fi

print_status "Step 4: Checking project access..."
if timeout 10 gcloud projects describe "$PROJECT_ID" &> /dev/null; then
    print_success "Can access project: $PROJECT_ID"
else
    print_error "Cannot access project: $PROJECT_ID"
    exit 1
fi

print_status "Step 5: Checking gsutil..."
if command -v gsutil &> /dev/null; then
    print_success "gsutil command found"
    
    print_status "Step 6: Testing storage access..."
    if timeout 10 gsutil ls -p "$PROJECT_ID" &> /dev/null; then
        print_success "Can access storage"
    else
        print_error "Cannot access storage"
    fi
else
    print_error "gsutil command not found"
fi

print_status "Minimal verification complete"