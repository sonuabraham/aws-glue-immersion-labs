#!/bin/bash
echo 'Setup environment'
#!/bin/bash
# ============================================================
# AWS Glue Immersion Day - Offline One-Step Setup Script
# ============================================================
# Usage:
#   . ./library/one-step-setup.sh ./ my-glue-bucket
#
# Description:
#   This script sets up local lab folders and syncs them to S3
#   so that AWS Glue Studio or Notebook environments can access
#   data and scripts without using the workshop URLs.
# ============================================================

set -e

# --- Input Arguments ---
BASE_PATH=${1:-"./"}
S3_BUCKET=${2:-""}

if [ -z "$S3_BUCKET" ]; then
  echo "❌ ERROR: You must provide your target S3 bucket name."
  echo "Usage: . ./library/one-step-setup.sh ./ <your-s3-bucket>"
  return 1
fi

# --- Verify base path ---
if [ ! -d "$BASE_PATH" ]; then
  echo "❌ Base path '$BASE_PATH' not found!"
  return 1
fi

echo "=============================="
echo "AWS Glue Offline Setup Script"
echo "=============================="
echo "Base Path : $BASE_PATH"
echo "S3 Bucket : $S3_BUCKET"
echo "=============================="

# --- Create S3 bucket if not exists ---
if ! aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
  echo "✅ S3 bucket exists: $S3_BUCKET"
else
  echo "🪣 Creating S3 bucket: $S3_BUCKET ..."
  aws s3 mb s3://$S3_BUCKET
fi

# --- Sync lab folders ---
echo "📤 Uploading local lab data to S3..."
aws s3 sync "$BASE_PATH" "s3://$S3_BUCKET/" --exclude "*.zip" --exclude "*.sh"

# --- Create a local summary ---
echo "📁 Creating setup summary file..."
cat <<EOF > "$BASE_PATH/setup-summary.txt"
AWS Glue Workshop Setup Summary
===============================
Date: $(date)
Local Path: $BASE_PATH
S3 Bucket: $S3_BUCKET

Uploaded Labs:
$(find "$BASE_PATH" -maxdepth 1 -type d -name "lab*" -exec basename {} \;)
EOF

echo "✅ Setup complete!"
echo "Your data and scripts are now available in: s3://$S3_BUCKET/"
echo "Use these paths in AWS Glue Studio when creating jobs or crawlers."
