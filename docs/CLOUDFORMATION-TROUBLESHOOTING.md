# CloudFormation Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: Crawler CREATE_FAILED (Lab8MockCaseCrawler, MLCrawlerSample, MLCrawlerBootstrap)

**Error Messages:**
```
Unable to validate s3 target s3://glueworkshop-{account}-{region}/input/lab1/csv/ 
because: Not Found (Service: Amazon S3; Status Code: 404; Error Code: 404 Not Found)
```
or
```
Unable to validate s3 target s3://glueworkshop-{account}-{region}/ml-lab/customer_sampling/
because: Not Found (Service: Amazon S3; Status Code: 404; Error Code: 404 Not Found)
```

**Cause:** The crawlers try to validate S3 paths that don't exist yet during stack creation. Data is uploaded later by the setup script.

**Solution:** This has been fixed in `GlueImmersionDay-LocalDeployment-v2.yaml`. The Lab 8 and ML crawlers have been removed from the CloudFormation template.

**If you already deployed the old template:**
1. Delete the failed stack:
   ```bash
   aws cloudformation delete-stack --stack-name glue-workshop
   ```

2. Wait for deletion to complete:
   ```bash
   aws cloudformation wait stack-delete-complete --stack-name glue-workshop
   ```

3. Deploy the updated template:
   ```bash
   aws cloudformation create-stack \
     --stack-name glue-workshop \
     --template-body file://infra/GlueImmersionDay-LocalDeployment-v2.yaml \
     --capabilities CAPABILITY_NAMED_IAM
   ```

**To create Lab 8 and ML crawlers later:**
After running the setup script and uploading data, run:
```bash
chmod +x scripts/create-optional-crawlers.sh
./scripts/create-optional-crawlers.sh
```

### Issue 2: S3 Bucket Already Exists

**Error Message:**
```
Resource creation cancelled
glueworkshop-{account}-{region} already exists
```

**Cause:** The S3 bucket name is globally unique and already exists (from a previous deployment).

**Solution:**
1. Delete the existing bucket:
   ```bash
   aws s3 rb s3://glueworkshop-${AWS_ACCOUNT_ID}-${AWS_REGION} --force
   ```

2. Retry the CloudFormation stack creation

**Alternative:** Modify the bucket name in the template to make it unique.

### Issue 3: IAM Role Already Exists

**Error Message:**
```
Role with name AWSGlueServiceRole-glueworkshop already exists
```

**Cause:** The IAM role from a previous deployment still exists.

**Solution:**
1. Delete the existing roles:
   ```bash
   aws iam delete-role --role-name AWSGlueServiceRole-glueworkshop
   aws iam delete-role --role-name AWSGlueDataBrewServiceRole-glueworkshop
   aws iam delete-role --role-name AWSEventBridgeInvokeRole-glueworkshop
   aws iam delete-role --role-name AWSStepFunctionRole-glueworkshop
   aws iam delete-role --role-name MWAAIAMRole
   ```

2. Note: You may need to detach policies first:
   ```bash
   aws iam list-attached-role-policies --role-name AWSGlueServiceRole-glueworkshop
   aws iam detach-role-policy --role-name AWSGlueServiceRole-glueworkshop --policy-arn <policy-arn>
   ```

3. Retry the CloudFormation stack creation

### Issue 4: RDS MySQL Version Not Available

**Error Message:**
```
Cannot find version 8.0.32 for mysql
(Service: Rds, Status Code: 400, Request ID: ...)
```

**Cause:** The specified MySQL version is not available in your region.

**Solution:**
1. Check available MySQL versions in your region:
   ```bash
   aws rds describe-db-engine-versions \
     --engine mysql \
     --query "DBEngineVersions[?starts_with(EngineVersion, '8.0')].EngineVersion" \
     --output table \
     --region <your-region>
   ```

2. Update the template with an available version:
   ```yaml
   EngineVersion: 8.0.35  # or another available version
   ```

3. Or remove the `EngineVersion` line to use the default latest version

**Note:** The template has been updated to use 8.0.35, which is more widely available.

### Issue 5: CloudTrail S3 Bucket Policy Error

**Error Message:**
```
Invalid request provided: Incorrect S3 bucket policy is detected for bucket: glueworkshop-...
(Service: CloudTrail, Status Code: 400, Request ID: ...)
```

**Cause:** CloudTrail is trying to use the S3 bucket before the bucket policy is fully applied.

**Solution:** This has been fixed in `GlueImmersionDay-LocalDeployment-v2.yaml` by adding proper `DependsOn` to the Trail resource.

**If you encounter this:**
1. Delete the failed stack
2. Redeploy with the updated template

The Trail resource now explicitly depends on both S3Bucket and S3BucketPolicy.

### Issue 6: RDS Instance Creation Timeout

**Error Message:**
```
Resource creation cancelled
Waiter DBInstanceAvailable failed: Max attempts exceeded
```

**Cause:** RDS instance creation is taking longer than expected.

**Solution:**
1. Check RDS console to see if the instance is still being created
2. If it's still creating, wait for it to complete
3. If it failed, check the RDS events for the specific error
4. Common causes:
   - Insufficient capacity in the AZ
   - Invalid parameter combinations
   - Service limits reached

**Workaround:** Try a different instance class or region.

### Issue 5: MWAA Environment Creation Failed

**Error Message:**
```
Unable to create MWAA environment
```

**Cause:** MWAA has specific requirements for networking and S3.

**Solution:**
1. Verify the S3 bucket exists and has the correct structure
2. Check that the VPC has:
   - Private subnets with NAT gateways
   - Proper security group rules
3. Ensure the IAM role has correct permissions
4. Check MWAA service limits in your account

**Note:** MWAA is optional for most labs. You can comment it out in the template if not needed.

### Issue 6: VPC Limit Exceeded

**Error Message:**
```
The maximum number of VPCs has been reached
```

**Cause:** AWS account has reached the VPC limit (default is 5 per region).

**Solution:**
1. Delete unused VPCs:
   ```bash
   aws ec2 describe-vpcs
   aws ec2 delete-vpc --vpc-id <vpc-id>
   ```

2. Or request a limit increase through AWS Support

3. Or use an existing VPC (modify the template)

### Issue 7: CloudFormation Stack Stuck in DELETE_FAILED

**Error Message:**
```
Stack is in DELETE_FAILED state
```

**Cause:** Some resources couldn't be deleted (often S3 buckets with content or ENIs).

**Solution:**
1. Check which resources failed:
   ```bash
   aws cloudformation describe-stack-events --stack-name glue-workshop \
     --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`]'
   ```

2. Manually delete the problematic resources:
   ```bash
   # For S3 buckets
   aws s3 rm s3://bucket-name --recursive
   aws s3 rb s3://bucket-name
   
   # For ENIs
   aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=<vpc-id>"
   aws ec2 delete-network-interface --network-interface-id <eni-id>
   ```

3. Retry stack deletion:
   ```bash
   aws cloudformation delete-stack --stack-name glue-workshop
   ```

## Best Practices

### 1. Clean Deployment
Always start with a clean slate:
```bash
# Check for existing resources
aws cloudformation describe-stacks --stack-name glue-workshop
aws s3 ls | grep glueworkshop
aws iam list-roles | grep -i glue

# Clean up if needed
./scripts/cleanup-all.sh  # Create this script for your environment
```

### 2. Validate Template Before Deployment
```bash
aws cloudformation validate-template \
  --template-body file://infra/GlueImmersionDay-LocalDeployment-v2.yaml
```

### 3. Use Change Sets for Updates
```bash
aws cloudformation create-change-set \
  --stack-name glue-workshop \
  --change-set-name update-$(date +%Y%m%d-%H%M%S) \
  --template-body file://infra/GlueImmersionDay-LocalDeployment-v2.yaml \
  --capabilities CAPABILITY_NAMED_IAM

# Review changes
aws cloudformation describe-change-set \
  --stack-name glue-workshop \
  --change-set-name <change-set-name>

# Execute if looks good
aws cloudformation execute-change-set \
  --stack-name glue-workshop \
  --change-set-name <change-set-name>
```

### 4. Monitor Stack Creation
```bash
# Watch stack events in real-time
watch -n 5 'aws cloudformation describe-stack-events \
  --stack-name glue-workshop \
  --max-items 10 \
  --query "StackEvents[*].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId]" \
  --output table'
```

### 5. Enable Termination Protection
After successful deployment:
```bash
aws cloudformation update-termination-protection \
  --stack-name glue-workshop \
  --enable-termination-protection
```

## Debugging Commands

### Check Stack Status
```bash
aws cloudformation describe-stacks \
  --stack-name glue-workshop \
  --query 'Stacks[0].StackStatus'
```

### Get Stack Outputs
```bash
aws cloudformation describe-stacks \
  --stack-name glue-workshop \
  --query 'Stacks[0].Outputs'
```

### List Stack Resources
```bash
aws cloudformation list-stack-resources \
  --stack-name glue-workshop
```

### Get Failed Resource Details
```bash
aws cloudformation describe-stack-events \
  --stack-name glue-workshop \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
```

## Recovery Procedures

### Scenario 1: Partial Stack Creation
If some resources were created before failure:

1. Note which resources were created successfully
2. Delete the stack
3. Manually delete any orphaned resources
4. Redeploy

### Scenario 2: Stack Rollback
If CloudFormation automatically rolled back:

1. Check the events to see what failed
2. Fix the issue (usually in the template or prerequisites)
3. Delete the rolled-back stack
4. Redeploy with fixes

### Scenario 3: Update Failed
If a stack update failed:

1. Stack will be in UPDATE_ROLLBACK_COMPLETE state
2. Review what changed
3. Either:
   - Fix and retry the update
   - Or delete and recreate the stack

## Getting Help

### CloudFormation Logs
Check CloudWatch Logs for detailed error messages:
```bash
aws logs tail /aws/cloudformation/glue-workshop --follow
```

### AWS Support
If you're stuck, contact AWS Support with:
- Stack name
- Stack events (JSON export)
- Template file
- Error messages

### Community Resources
- AWS re:Post: https://repost.aws/
- Stack Overflow: Tag with `amazon-cloudformation` and `aws-glue`
- AWS Glue Documentation: https://docs.aws.amazon.com/glue/

## Prevention

### Pre-Deployment Checklist
- [ ] Validate template syntax
- [ ] Check service limits
- [ ] Verify IAM permissions
- [ ] Ensure no naming conflicts
- [ ] Review estimated costs
- [ ] Have rollback plan ready

### Post-Deployment Checklist
- [ ] Verify all resources created
- [ ] Test basic functionality
- [ ] Document any manual steps
- [ ] Set up monitoring/alerts
- [ ] Enable termination protection
