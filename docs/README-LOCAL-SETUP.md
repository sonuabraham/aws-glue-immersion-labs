# AWS Glue Workshop - Local Deployment Guide

This guide helps you run the AWS Glue Workshop from your local laptop instead of Cloud9.

## Prerequisites

1. **AWS CLI** configured with credentials that have permissions to:
   - Create VPC, subnets, security groups
   - Create RDS instances
   - Create S3 buckets
   - Create Glue resources (databases, tables, crawlers, jobs)
   - Create IAM roles and policies
   - Create MWAA environments
   - Create CloudTrail, SQS, Kinesis, SNS resources

2. **WSL** (Windows Subsystem for Linux) or Linux/Mac terminal

3. **AWS Account** with sufficient permissions

## Setup Steps

### 1. Deploy CloudFormation Stack

First, deploy the infrastructure using the updated CloudFormation template:

```bash
aws cloudformation create-stack \
  --stack-name glue-workshop \
  --template-body file://GlueImmersionDay-LocalDeployment-v2.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region <your-region>
```

Wait for the stack to complete:
```bash
aws cloudformation wait stack-create-complete \
  --stack-name glue-workshop \
  --region <your-region>
```

### 2. Create Workshop Files

Run the script to create the glue-workshop directory structure:

```bash
chmod +x create-glue-workshop-zip.sh
./create-glue-workshop-zip.sh
```

This creates:
- `glue-workshop/code/` - Your Glue ETL scripts
- `glue-workshop/data/` - Sample data for labs
- `glue-workshop/library/` - Python libraries
- `glue-workshop/airflow/` - MWAA DAGs and configuration

### 3. Customize Your Workshop Files

Add your own Glue scripts and data:
- Place Glue ETL scripts in `glue-workshop/code/`
- Add additional data files to `glue-workshop/data/`
- Customize Airflow DAGs in `glue-workshop/airflow/dags/`

### 4. Create the ZIP File

```bash
zip -r glue-workshop.zip glue-workshop/
```

### 5. Place ZIP in Environment Directory

```bash
mkdir -p ~/environment
cp glue-workshop.zip ~/environment/
```

### 6. Run the Setup Script

The setup script will:
- Extract the workshop files
- Upload content to S3
- Create Glue tables
- Set up MWAA environment
- Install required libraries

```bash
cd ~/environment
chmod +x one-step-setup.sh
./one-step-setup.sh "<workshop-url-or-dummy-value>"
```

**Note:** The workshop URL parameter is optional now. If you don't have one, just pass a dummy value like "local".

## What Changed from Cloud9 Version

### Removed:
- Cloud9 IDE resource
- EC2 instance profile setup
- Cloud9 security group configuration
- EC2 metadata queries
- Automatic credential management

### Added:
- Better error handling for unavailable resources
- Sample COVID-19 data (since public data lake is not accessible)
- Local credential validation
- Graceful handling of missing files

### Modified:
- S3 uploads now show progress and handle errors
- Script continues even if optional downloads fail
- Uses your local AWS CLI credentials

## Troubleshooting

### Access Denied Errors
If you see "Access Denied" errors for public S3 buckets (like COVID-19 data lake), this is expected. The script includes sample data as a fallback.

### Missing pycountry_convert.zip
If the pycountry library download fails, you can:
1. Install it manually: `pip install pycountry-convert`
2. Create a zip and place it in `glue-workshop/library/`
3. Skip it if your labs don't require it

### AWS Credentials
Make sure your AWS CLI is configured:
```bash
aws configure
aws sts get-caller-identity
```

### Region Mismatch
Ensure you're using the same region throughout:
```bash
export AWS_REGION=<your-region>
aws configure set region $AWS_REGION
```

## Environment Variables

After setup completes, these variables are set in your `~/.bashrc`:
- `BUCKET_NAME` - Your workshop S3 bucket
- `AWS_REGION` - Your AWS region
- `AWS_ACCOUNT_ID` - Your AWS account ID

Reload them:
```bash
source ~/.bashrc
```

## Cleanup

To remove all resources:

```bash
# Empty the S3 bucket first
aws s3 rm s3://glueworkshop-${AWS_ACCOUNT_ID}-${AWS_REGION} --recursive

# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name glue-workshop --region <your-region>
```

## Notes

- The MWAA environment takes 20-30 minutes to create
- RDS instance creation takes 10-15 minutes
- Some mock Glue jobs from the original template were removed as they referenced unavailable S3 scripts
- You can add them back manually if you have the scripts

## Support

If you encounter issues:
1. Check CloudFormation stack events for errors
2. Verify IAM permissions
3. Check CloudWatch logs for Glue jobs
4. Ensure S3 bucket was created successfully
