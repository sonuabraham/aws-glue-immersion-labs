#!/bin/bash

# Script to create Lab 8 and ML crawlers after data has been uploaded
# Run this AFTER running one-step-setup.sh

echo "Creating Lab 8 and ML crawlers..."

# Get environment variables
if [ -z "$BUCKET_NAME" ]; then
    echo "Error: BUCKET_NAME environment variable not set"
    echo "Run: source ~/.bashrc"
    exit 1
fi

# Create Lab 8 COVID case crawler
echo "Creating lab8-covid-case-count-processed-crawler..."
aws glue create-crawler \
  --name lab8-covid-case-count-processed-crawler \
  --role AWSGlueServiceRole-glueworkshop \
  --database-name glueworkshop_cloudformation \
  --table-prefix lab8-case-processed- \
  --targets "{\"S3Targets\":[{\"Path\":\"s3://${BUCKET_NAME}/input/lab1/csv/\"}]}" \
  --region $AWS_REGION

if [ $? -eq 0 ]; then
    echo "✓ COVID case crawler created successfully"
else
    echo "✗ Failed to create COVID case crawler (may already exist)"
fi

# Create Lab 8 vaccine crawler
echo "Creating lab8-vaccine-case-count-processed-crawler..."
aws glue create-crawler \
  --name lab8-vaccine-case-count-processed-crawler \
  --role AWSGlueServiceRole-glueworkshop \
  --database-name glueworkshop_cloudformation \
  --table-prefix lab8-vaccine-processed- \
  --targets "{\"S3Targets\":[{\"Path\":\"s3://${BUCKET_NAME}/input/lab1/csv/\"}]}" \
  --region $AWS_REGION

if [ $? -eq 0 ]; then
    echo "✓ Vaccine crawler created successfully"
else
    echo "✗ Failed to create vaccine crawler (may already exist)"
fi

# Create ML crawlers (if ML lab data exists)
echo ""
echo "Creating ML crawlers..."

echo "Creating ml-sample-cust-crawler..."
aws glue create-crawler \
  --name ml-sample-cust-crawler \
  --role AWSGlueServiceRole-glueworkshop \
  --database-name glueworkshop_cloudformation \
  --table-prefix ml_ \
  --targets "{\"S3Targets\":[{\"Path\":\"s3://${BUCKET_NAME}/ml-lab/customer_sampling/\"}]}" \
  --region $AWS_REGION 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ ML sample crawler created successfully"
else
    echo "✗ Failed to create ML sample crawler (may already exist or data path doesn't exist)"
fi

echo "Creating ml-bootstrap-crawler..."
aws glue create-crawler \
  --name ml-bootstrap-crawler \
  --role AWSGlueServiceRole-glueworkshop \
  --database-name glueworkshop_cloudformation \
  --table-prefix ml_to_dedup_ \
  --targets "{\"S3Targets\":[{\"Path\":\"s3://${BUCKET_NAME}/ml-lab/top-customer/\"}]}" \
  --region $AWS_REGION 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ ML bootstrap crawler created successfully"
else
    echo "✗ Failed to create ML bootstrap crawler (may already exist or data path doesn't exist)"
fi

echo ""
echo "Crawlers created. You can now run them:"
echo "  Lab 8 crawlers:"
echo "    aws glue start-crawler --name lab8-covid-case-count-processed-crawler"
echo "    aws glue start-crawler --name lab8-vaccine-case-count-processed-crawler"
echo "  ML crawlers:"
echo "    aws glue start-crawler --name ml-sample-cust-crawler"
echo "    aws glue start-crawler --name ml-bootstrap-crawler"
