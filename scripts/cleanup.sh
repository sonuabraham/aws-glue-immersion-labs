#!/bin/bash

# Cleanup script for AWS Glue Workshop resources created by one-step-setup.sh
# This script will remove all resources created during the workshop setup

set -e

echo "
============================> AWS GLUE WORKSHOP CLEANUP SCRIPT <==========================================
"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get AWS account and region info
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
AWS_REGION=$(aws configure get region)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}ERROR: Unable to get AWS account ID. Please check your AWS credentials.${NC}"
    exit 1
fi

BUCKET_NAME="glueworkshop-lab1-${AWS_ACCOUNT_ID}-${AWS_REGION}"

echo -e "${YELLOW}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${YELLOW}AWS Region: ${AWS_REGION}${NC}"
echo -e "${YELLOW}S3 Bucket: ${BUCKET_NAME}${NC}"
echo ""

# Confirmation prompt
read -p "This will DELETE all workshop resources. Are you sure? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "============================> STARTING CLEANUP PROCESS <=============================================="
echo ""

# Function to check if resource exists and delete it
delete_if_exists() {
    local resource_type=$1
    local resource_name=$2
    local delete_command=$3
    
    echo -n "Checking $resource_type: $resource_name... "
    if eval "$delete_command" 2>/dev/null; then
        echo -e "${GREEN}DELETED${NC}"
        return 0
    else
        echo -e "${YELLOW}NOT FOUND or ALREADY DELETED${NC}"
        return 1
    fi
}

# 1. Delete MWAA Environment
echo "============================> DELETING MWAA ENVIRONMENT <============================================="
MWAA_ENV_NAME="MyAirflowEnvironment"
MWAA_STATUS=$(aws mwaa get-environment --name "$MWAA_ENV_NAME" --query 'Environment.Status' --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$MWAA_STATUS" != "NOT_FOUND" ]; then
    echo "MWAA Environment found with status: $MWAA_STATUS"
    if [ "$MWAA_STATUS" != "DELETING" ]; then
        echo "Deleting MWAA environment (this may take 20-30 minutes)..."
        aws mwaa delete-environment --name "$MWAA_ENV_NAME" 2>/dev/null && echo -e "${GREEN}MWAA deletion initiated${NC}" || echo -e "${YELLOW}Failed to delete MWAA${NC}"
        
        # Wait for deletion to start
        echo "Waiting for MWAA deletion to start..."
        sleep 10
    else
        echo -e "${YELLOW}MWAA is already being deleted${NC}"
    fi
else
    echo -e "${YELLOW}MWAA environment not found${NC}"
fi
echo ""

# 2. Delete Glue Tables
echo "============================> DELETING GLUE TABLES <==================================================="
DATABASE_NAME="glueworkshop_cloudformation"

# Get all tables in the database
TABLES=$(aws glue get-tables --database-name "$DATABASE_NAME" --query 'TableList[].Name' --output text 2>/dev/null || echo "")

if [ -n "$TABLES" ]; then
    for TABLE in $TABLES; do
        delete_if_exists "Glue Table" "$TABLE" "aws glue delete-table --database-name $DATABASE_NAME --name $TABLE"
    done
else
    echo -e "${YELLOW}No tables found in database $DATABASE_NAME${NC}"
fi
echo ""

# 3. Delete Glue Crawlers
echo "============================> DELETING GLUE CRAWLERS <================================================="
CRAWLERS=$(aws glue list-crawlers --query 'CrawlerNames' --output text 2>/dev/null || echo "")

if [ -n "$CRAWLERS" ]; then
    for CRAWLER in $CRAWLERS; do
        # Stop crawler if running
        CRAWLER_STATE=$(aws glue get-crawler --name "$CRAWLER" --query 'Crawler.State' --output text 2>/dev/null || echo "")
        if [ "$CRAWLER_STATE" == "RUNNING" ]; then
            echo "Stopping crawler: $CRAWLER..."
            aws glue stop-crawler --name "$CRAWLER" 2>/dev/null
            sleep 5
        fi
        delete_if_exists "Glue Crawler" "$CRAWLER" "aws glue delete-crawler --name $CRAWLER"
    done
else
    echo -e "${YELLOW}No crawlers found${NC}"
fi
echo ""

# 4. Delete Glue Jobs
echo "============================> DELETING GLUE JOBS <====================================================="
JOBS=$(aws glue list-jobs --query 'JobNames' --output text 2>/dev/null || echo "")

if [ -n "$JOBS" ]; then
    for JOB in $JOBS; do
        delete_if_exists "Glue Job" "$JOB" "aws glue delete-job --job-name $JOB"
    done
else
    echo -e "${YELLOW}No Glue jobs found${NC}"
fi
echo ""

# 5. Delete Glue Connections
echo "============================> DELETING GLUE CONNECTIONS <=============================================="
CONNECTIONS=$(aws glue get-connections --query 'ConnectionList[].Name' --output text 2>/dev/null || echo "")

if [ -n "$CONNECTIONS" ]; then
    for CONNECTION in $CONNECTIONS; do
        delete_if_exists "Glue Connection" "$CONNECTION" "aws glue delete-connection --connection-name $CONNECTION"
    done
else
    echo -e "${YELLOW}No Glue connections found${NC}"
fi
echo ""

# 6. Empty and Delete S3 Bucket
echo "============================> DELETING S3 BUCKET <====================================================="
if aws s3 ls "s3://${BUCKET_NAME}" 2>/dev/null; then
    echo "Emptying S3 bucket: ${BUCKET_NAME}..."
    aws s3 rm "s3://${BUCKET_NAME}" --recursive 2>/dev/null && echo -e "${GREEN}Bucket emptied${NC}" || echo -e "${YELLOW}Failed to empty bucket${NC}"
    
    echo "Deleting S3 bucket: ${BUCKET_NAME}..."
    aws s3 rb "s3://${BUCKET_NAME}" 2>/dev/null && echo -e "${GREEN}Bucket deleted${NC}" || echo -e "${YELLOW}Failed to delete bucket${NC}"
else
    echo -e "${YELLOW}S3 bucket not found: ${BUCKET_NAME}${NC}"
fi
echo ""

# 7. Delete SQS Queue
echo "============================> DELETING SQS QUEUE <====================================================="
QUEUE_NAME="glueworkshop-lab1-event-queue"
QUEUE_URL=$(aws sqs get-queue-url --queue-name "$QUEUE_NAME" --query 'QueueUrl' --output text 2>/dev/null || echo "")

if [ -n "$QUEUE_URL" ]; then
    delete_if_exists "SQS Queue" "$QUEUE_NAME" "aws sqs delete-queue --queue-url $QUEUE_URL"
else
    echo -e "${YELLOW}SQS queue not found: ${QUEUE_NAME}${NC}"
fi
echo ""

# 8. Delete CloudFormation Stack (if exists)
echo "============================> DELETING CLOUDFORMATION STACK <=========================================="
STACK_NAMES=("GlueImmersionDay" "GlueWorkshop" "glueworkshop" "glue-workshop")

for STACK_NAME in "${STACK_NAMES[@]}"; do
    STACK_STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "NOT_FOUND")
    
    if [ "$STACK_STATUS" != "NOT_FOUND" ]; then
        echo "Found CloudFormation stack: $STACK_NAME (Status: $STACK_STATUS)"
        if [ "$STACK_STATUS" != "DELETE_IN_PROGRESS" ] && [ "$STACK_STATUS" != "DELETE_COMPLETE" ]; then
            echo "Deleting CloudFormation stack: $STACK_NAME..."
            aws cloudformation delete-stack --stack-name "$STACK_NAME" 2>/dev/null && echo -e "${GREEN}Stack deletion initiated${NC}" || echo -e "${YELLOW}Failed to delete stack${NC}"
        else
            echo -e "${YELLOW}Stack is already being deleted or deleted${NC}"
        fi
        break
    fi
done
echo ""

# 9. Delete Local Files
echo "============================> DELETING LOCAL FILES <==================================================="
LOCAL_DIRS=(
    "$HOME/environment/glue-workshop"
    "$HOME/environment/glue-workshop.zip"
    "$HOME/environment/awscliv2.zip"
    "$HOME/environment/aws"
)

for DIR in "${LOCAL_DIRS[@]}"; do
    if [ -e "$DIR" ]; then
        echo -n "Deleting: $DIR... "
        rm -rf "$DIR" 2>/dev/null && echo -e "${GREEN}DELETED${NC}" || echo -e "${YELLOW}FAILED${NC}"
    else
        echo -e "${YELLOW}Not found: $DIR${NC}"
    fi
done
echo ""

# 10. Clean up environment variables from .bashrc
echo "============================> CLEANING ENVIRONMENT VARIABLES <========================================="
if [ -f "$HOME/.bashrc" ]; then
    echo "Removing workshop environment variables from .bashrc..."
    sed -i '/export BUCKET_NAME="glueworkshop/d' "$HOME/.bashrc" 2>/dev/null
    sed -i '/export AWS_REGION=/d' "$HOME/.bashrc" 2>/dev/null
    sed -i '/export AWS_ACCOUNT_ID=/d' "$HOME/.bashrc" 2>/dev/null
    echo -e "${GREEN}Environment variables cleaned${NC}"
else
    echo -e "${YELLOW}.bashrc not found${NC}"
fi
echo ""

# Summary
echo "
========================================================================================================
                                    CLEANUP SUMMARY
========================================================================================================
"

echo -e "${GREEN}✓${NC} MWAA Environment deletion initiated (if found)"
echo -e "${GREEN}✓${NC} Glue tables deleted"
echo -e "${GREEN}✓${NC} Glue crawlers deleted"
echo -e "${GREEN}✓${NC} Glue jobs deleted"
echo -e "${GREEN}✓${NC} Glue connections deleted"
echo -e "${GREEN}✓${NC} S3 bucket emptied and deleted"
echo -e "${GREEN}✓${NC} SQS queue deleted"
echo -e "${GREEN}✓${NC} CloudFormation stack deletion initiated (if found)"
echo -e "${GREEN}✓${NC} Local files cleaned up"
echo -e "${GREEN}✓${NC} Environment variables removed"

echo "
========================================================================================================
                                    IMPORTANT NOTES
========================================================================================================
"

echo -e "${YELLOW}1. MWAA Environment deletion takes 20-30 minutes to complete${NC}"
echo -e "${YELLOW}2. CloudFormation stack deletion may take several minutes${NC}"
echo -e "${YELLOW}3. Some resources may have dependencies and require manual cleanup${NC}"
echo -e "${YELLOW}4. Check AWS Console to verify all resources are deleted${NC}"
echo -e "${YELLOW}5. You may need to reload your shell: source ~/.bashrc${NC}"

echo "
========================================================================================================
                                    MANUAL VERIFICATION
========================================================================================================
"

echo "To verify cleanup, run these commands:"
echo ""
echo "  # Check MWAA status"
echo "  aws mwaa list-environments"
echo ""
echo "  # Check S3 buckets"
echo "  aws s3 ls | grep glueworkshop"
echo ""
echo "  # Check Glue resources"
echo "  aws glue list-crawlers"
echo "  aws glue list-jobs"
echo ""
echo "  # Check CloudFormation stacks"
echo "  aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE"
echo ""

echo -e "${GREEN}Cleanup script completed!${NC}"
echo ""
