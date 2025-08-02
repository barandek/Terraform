#!/bin/bash

# Simple test script to debug the verification issues

PROJECT_ID="$1"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 PROJECT_ID"
    exit 1
fi

echo "Testing basic commands for project: $PROJECT_ID"
echo ""

echo "1. Testing gcloud command:"
if command -v gcloud &> /dev/null; then
    echo "✓ gcloud found"
    gcloud version 2>/dev/null | head -3 || echo "✗ gcloud version failed"
else
    echo "✗ gcloud not found"
fi
echo ""

echo "2. Testing gsutil command:"
if command -v gsutil &> /dev/null; then
    echo "✓ gsutil found"
    gsutil version 2>/dev/null | head -1 || echo "✗ gsutil version failed"
else
    echo "✗ gsutil not found"
fi
echo ""

echo "3. Testing terraform command:"
if command -v terraform &> /dev/null; then
    echo "✓ terraform found"
    terraform version 2>/dev/null | head -1 || echo "✗ terraform version failed"
else
    echo "✗ terraform not found"
fi
echo ""

echo "4. Testing gcloud auth:"
active_account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)
if [[ -n "$active_account" ]]; then
    echo "✓ Authenticated as: $active_account"
else
    echo "✗ Not authenticated"
fi
echo ""

echo "5. Testing project access:"
if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
    echo "✓ Can access project: $PROJECT_ID"
else
    echo "✗ Cannot access project: $PROJECT_ID"
    echo "Available projects:"
    gcloud projects list --format="value(projectId)" 2>/dev/null | head -5
fi
echo ""

echo "6. Testing basic storage access:"
if gsutil ls -p "$PROJECT_ID" &> /dev/null; then
    echo "✓ Can access storage"
else
    echo "✗ Cannot access storage"
fi
echo ""

echo "Test complete."