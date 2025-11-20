#!/bin/sh

URL=$1


echo "
============================> THIS SCRIPT WILL TAKE FEW SECONDS TO COMPLETE - PLEASE WAIT! <==============================================================================
"

##SETTING UP ENVIROMENT VARIABLES
echo "
============================> SETTING UP ENVIROMENT VARIABLES <===========================================================================================================
"
AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`

# need to have a default fall back to us-east-2 for infra
AWS_REGION=$(aws configure get region || echo "us-east-2")


# CFN: BucketName: !Sub 'glueworkshop-${AWS::AccountId}-${AWS::Region}'
BUCKET_NAME=glueworkshop-${AWS_ACCOUNT_ID}-${AWS_REGION}
echo " "
echo "export BUCKET_NAME=\"${BUCKET_NAME}\"" >> /home/participant/.bashrc
echo "export AWS_REGION=\"${AWS_REGION}\"" >> /home/participant/.bashrc
echo "export AWS_ACCOUNT_ID=\"${AWS_ACCOUNT_ID}\"" >> /home/participant/.bashrc

. ~/.bash_profile

## CREATING LOCAL VISUAL STUDIO DIRECTORIES, DOWNLOADING CONTENT AND UPLOADING BACK TO S3 - THIS WILL TURN INTO S3 FOLDERS AND FILES
echo "============================> MAKING UP LOCAL DIRECTORIES <==============================================================================================================="

cd /project
aws s3 cp s3://ws-assets-prod-iad-r-cmh-8d6e9c21a4dec77d/ee59d21b-4cb8-4b3d-a629-24537cf37bb5/glue-workshop.zip glue-workshop.zip > /dev/null
unzip glue-workshop.zip > /dev/null
mkdir /project/glue-workshop/output > /dev/null


# $(curl -s 'https://static.us-east-1.prod.workshops.aws/61a632db-6c2a-40ce-83b8-1be1798ab6d5/static/download/howtostart/awseevnt/s3-and-local-file/one-step-setup.sh?Key-Pair-Id=K36Q2WVO3JP7QD&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zdGF0aWMudXMtZWFzdC0xLnByb2Qud29ya3Nob3BzLmF3cy82MWE2MzJkYi02YzJhLTQwY2UtODNiOC0xYmUxNzk4YWI2ZDUvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc0MzQ1MjY0OX19fV19&Signature=OXcwfj7v0w-pZbttoBNkNzo~Tkegv~utDV9AYLftQuhFjCezfB~8DMPOyMN~s7RyS5euf8xt56dYxkWaCvKMGay~duJZ1ZJLjAbKf~1s6p~4bYFYhwG-4dPhsl42pZVFw~FPj7hxtzYk5NvkysTrXS2Tq2tOGmSCtdW-n6U57qDAXw6sY8i7qaM~~nVpzeI1K~SDILTJge5YZJiVs3HnZgUJlf2aEHZJ19CplI1MzHOXhsvZKv1wYjqc3Uh-AEypC5xquVOkOvL~ztaYpgJ0Dos85jYLXYO4euY3QkYgMU8vLpwfC7GoxLDluCqE~YK~WKc2Sa0dYMKvwh48o5aC9w__' --output /project/glue-workshop/library/one-step-setup.sh --create-dirs)


### CHECKING WHICH URLS TO BUILD
len=`echo $URL |awk '{print length}'`

if [ $len -lt 150 ]; then
### BUILDING SMALLER URL VERSION

URL="https://static.us-east-1.prod.workshops.aws/61a632db-6c2a-40ce-83b8-1be1798ab6d5/static/0/?Key-Pair-Id=K36Q2WVO3JP7QD&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zdGF0aWMudXMtZWFzdC0xLnByb2Qud29ya3Nob3BzLmF3cy82MWE2MzJkYi02YzJhLTQwY2UtODNiOC0xYmUxNzk4YWI2ZDUvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc0MzQ1MjY0OX19fV19&Signature=OXcwfj7v0w-pZbttoBNkNzo~Tkegv~utDV9AYLftQuhFjCezfB~8DMPOyMN~s7RyS5euf8xt56dYxkWaCvKMGay~duJZ1ZJLjAbKf~1s6p~4bYFYhwG-4dPhsl42pZVFw~FPj7hxtzYk5NvkysTrXS2Tq2tOGmSCtdW-n6U57qDAXw6sY8i7qaM~~nVpzeI1K~SDILTJge5YZJiVs3HnZgUJlf2aEHZJ19CplI1MzHOXhsvZKv1wYjqc3Uh-AEypC5xquVOkOvL~ztaYpgJ0Dos85jYLXYO4euY3QkYgMU8vLpwfC7GoxLDluCqE~YK~WKc2Sa0dYMKvwh48o5aC9w__";
var1=$(echo $URL | grep -oP "public/.*?/" | cut -c 8-43) 

echo "

Build-ID  = $var1

"

echo "============================> DOWNLOADING CONTENT INTO THE DIRECTORIES <==================================================================================================
# PYCOUNTRY LIBRARY: pycountry_convert.zip
$(curl -s 'https://static.us-east-1.prod.workshops.aws/public/'$var1'/static/download/howtostart/awseevnt/s3-and-local-file/pycountry_convert.zip' --output /project/glue-workshop/library/pycountry_convert.zip)
==========================================================================================================================================================================
"

else
### BUILDING LONGER URL VERSION

#Build-ID
var1=$(echo $URL | grep -oP "s/.*?/" | cut -c 3-38) 

#Key Pair Id
prefix="Key-Pair-Id="

var2=$(echo $URL | grep -oP "Key-Pair-Id=.*?&")
var2=${var2#"$prefix"}
var2=$(echo $var2 | tr -d '&')

#Policy
prefix="Policy="
var3=$(echo $URL | grep -oP "Policy=.*?&")
var3=${var3#"$prefix"}
var3=$(echo $var3 | tr -d '&')

#Signature
prefix="Signature="
var4=$(echo $URL | grep -oP "Signature=.*")
var4=${var4#"$prefix"}


echo "

Build-ID  = $var1

"

## CREATING LOCAL VISUAL STUDIO DIRECTORIES, DOWNLOADING CONTENT AND UPLOADING BACK TO S3 - THIS WILL TURN INTO S3 FOLDERS AND FILES
echo "============================> DOWNLOADING CONTENT INTO THE DIRECTORIES <==================================================================================================
# PYCOUNTRY LIBRARY: pycountry_convert.zip
$(curl -s 'https://static.us-east-1.prod.workshops.aws/'$var1'/static/download/howtostart/awseevnt/s3-and-local-file/pycountry_convert.zip?Key-Pair-Id='$var2'&Policy='$var3'&Signature='$var4'' --output /project/glue-workshop/library/pycountry_convert.zip)
==========================================================================================================================================================================
"

fi

echo "============================> UPLOADING EVERYTHING TO S3 <================================================================================================================
$(cd /project/glue-workshop)
$(aws s3 cp --recursive /project/glue-workshop/code/ s3://${BUCKET_NAME}/script/)
$(aws s3 cp --recursive /project/glue-workshop/data/ s3://${BUCKET_NAME}/input/)
$(aws s3 cp --recursive /project/glue-workshop/library/ s3://${BUCKET_NAME}/library/)
$(aws s3 cp --recursive s3://covid19-lake/rearc-covid-19-testing-data/json/states_daily/ s3://${BUCKET_NAME}/input/lab5/json/)
$(aws s3 cp --recursive /project/glue-workshop/airflow/ s3://${BUCKET_NAME}/airflow/)
==========================================================================================================================================================================
"

##SETTING UP REQUIRED SECURITY GROUPS INBOUND RULES 
echo "============================> SETTING UP INBOUND RULES <=================================================================================================================="
ref_sg=$(aws ec2 describe-security-groups --query 'SecurityGroups[?contains(GroupName, `glueimmersionday-vscode-code-server`) == `true`].GroupId' --output text)
target_sg=$(aws ec2 describe-security-groups --query 'SecurityGroups[?contains(GroupName, `DefaultVPCSecurityGroup`) == `true`].GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $target_sg --protocol -1 --source-group $ref_sg
echo "
==========================================================================================================================================================================
"

### MWAA Setup
echo "============================> SETTING UP MANAGED AIRFLOW ENVIRONMENT <=================================================================================================="
# Define the names of your subnets
subnet1_name="MWAAEnvironment Private Subnet (AZ1)"
subnet2_name="MWAAEnvironment Private Subnet (AZ2)"

# Retrieve the subnet IDs based on the subnet names
subnet1_id=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet1_name" --query 'Subnets[0].SubnetId' --output text)
subnet2_id=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet2_name" --query 'Subnets[0].SubnetId' --output text)

# Print the subnet IDs (optional)
echo "Subnet 1 ID: $subnet1_id"
echo "Subnet 2 ID: $subnet2_id"

# Define your parameters
NAME="MyAirflowEnvironment"
EXECUTION_ROLE_ARN=$(aws iam get-role --role-name MWAAIAMRole --query 'Role.Arn' --output text)
AIRFLOW_VERSION="2.10.1"
S3_BUCKET_ARN="arn:aws:s3:::${BUCKET_NAME}"
NETWORK_CONFIGURATION='{"SecurityGroupIds":["'"$target_sg"'"],"SubnetIds":["'"$subnet1_id"'","'"$subnet2_id"'"]}'

# Optional parameters
DAGS_FOLDER="airflow/dags/"	
PLUGINS_S3_PATH="airflow/plugins/awsairflowlib_222.zip"
REQUIREMENTS_S3_PATH="airflow/requirements/requirements.txt"
LOGGING_CONFIGURATION='{"TaskLogs":{"Enabled":true,"LogLevel":"INFO"}}'
ACCESS_MODE='PUBLIC_ONLY'
MAX_WORKER="4"
MIN_WORKER="1"

# Create the environment
aws mwaa create-environment \
  --name $NAME \
  --execution-role-arn $EXECUTION_ROLE_ARN \
  --source-bucket $S3_BUCKET_ARN \
  --airflow-version $AIRFLOW_VERSION \
  --network-configuration "$NETWORK_CONFIGURATION" \
  --dag-s3-path $DAGS_FOLDER \
  --plugins-s3-path $PLUGINS_S3_PATH \
  --requirements-s3-path $REQUIREMENTS_S3_PATH \
  --logging-configuration "$LOGGING_CONFIGURATION" \
  --webserver-access-mode "$ACCESS_MODE" \
  --max-workers $MAX_WORKER \
  --min-workers $MIN_WORKER

echo "Environment creation initiated. It may take 20-30 minutes to complete."

export PATH=$PATH:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/local/bin/aws > /dev/null

. ~/.bash_profile > /dev/null

#INSTALLING REQUIRED LIBRARIES (BOTO3 & PSQL CLIENT)
echo "============================> INSTALLING BOTO3 <=========================================================================================================================="
python3 -m ensurepip --default-pip  # Ensure pip is installed
python3 -m pip install --upgrade pip  # Upgrade to latest version
pip3 install boto3 --quiet
echo "=========================================================================================================================================================================="


echo "Get code-server instance ID"
inst_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=VSCodeServer" --query "Reservations[*].Instances[*].InstanceId" --output text)

echo "ASSOCIATING NEW INSTANCE PROFILE TO VS-CODE EC2 INSTANCE AND VERYFING ASSOCIATION"
inst_prof=$(aws ec2 describe-iam-instance-profile-associations --filters "Name=instance-id,Values=$inst_id" --query "IamInstanceProfileAssociations[*].AssociationId" --output text)

echo "============================> ASSOCIATING NEW INSTANCE PROFILE TO VISUAL STUDIO EC2 INSTANCE <============================================================================="
if [ -z $inst_prof ]
then
    echo "associating AWSEC2InstanceProfile-GlueWorkshop..."
    aws ec2 associate-iam-instance-profile --iam-instance-profile Name=AWSEC2InstanceProfile-GlueWorkshop --instance-id $inst_id
else
    echo "replacing:" $inst_prof "by AWSEC2InstanceProfile-GlueWorkshop"
    aws ec2 replace-iam-instance-profile-association --iam-instance-profile Name=AWSEC2InstanceProfile-GlueWorkshop --association-id $inst_prof
fi

echo "============================> VERYFYING ASSOCIATION <=====================================================================================================================
$(aws ec2 describe-iam-instance-profile-associations  --filters "Name=instance-id,Values=$inst_id" --query 'IamInstanceProfileAssociations[*].IamInstanceProfile.Arn' --output text > /tmp/msg.txt)
$(cat /tmp/msg.txt)
==========================================================================================================================================================================
"

. ~/.bash_profile > /dev/null

credArn=$(aws sts get-caller-identity --query Arn | grep AWSEC2ServiceRole-etl-ttt-demo | grep -oP "/.*?/" | cut -c 2-26)

while [ "$credArn" != "AWSEC2ServiceRole-etl-ttt" ]
do
    sleep 1s
    credArn=$(aws sts get-caller-identity --query Arn | grep AWSEC2ServiceRole-etl-ttt-demo | grep -oP "/.*?/" | cut -c 2-26)
done

##VALIDANTING NEW CREDENTIALS
echo "==================> VALIDATING CREDENTIALS <====================
$(aws configure set region $AWS_REGION)
$(aws sts get-caller-identity --query Arn | grep AWSEC2ServiceRole-etl-ttt-demo -q && echo "=====================> [IAM role valid] <=======================" || echo "==================> [IAM role NOT valid] <====================")
================================================================
"

. ~/.bash_profile

echo "

|========================================================================================================================================================================|
|########################################################################################################################################################################|
|##################################################################### SETUP SUCCESSFULLY COMPLETED #####################################################################|
|########################################################################################################################################################################|
|========================================================================================================================================================================|



|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|                                                        -->  1. DIRECTORIES BUILT & CONTENT DOWNLOADED LOCALLY                                                          |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                                                                                                                                      |
|  .. SUCCESS ..  | /project/glue-workshop/[cloudformation | code | data | library | output]                                                                        |
|                 |                                                                                                                                                      |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                      -->  2. CONTENT UPLOADED INTO RESPECTIVE S3 BUCKET PATHS                                                        |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                                                                                                                                      |
|  .. SUCCESS ..  | s3://$BUCKET_NAME/serverless-data-analytics/[input/ | library/ | script/ ]                                                    |
|                 |                                                                                                                                                      |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                      -->  3. AWS CLI, BOTO3 LIB, & PSQL CLIENT INSTALLED                                                             |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                                                                                                                                      |
| .. SUCCESS ..   | AWS CLI Version: $(aws --version)                                        |
| .. SUCCESS ..   | Boto3 Version: boto3==$(pip list |grep boto3 | awk '{print $2}')                                                                                                                        |
|                 |                                                                                                                                                      |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                      -->  4. NEW INSTANCE PROFILE ASSOCIATED                                                                         |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                                                                                                                                      |
|  .. SUCCESS ..  | $(cat /tmp/msg.txt)                                                                        |
|                 |                                                                                                                                                      |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                      -->  5. SECURITY GROUP INBOUD RULES SETUP                                                                       |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                                                                                                                                      |
|  .. SUCCESS ..  | Source SG: $ref_sg has been added to Target SG: $target_sg                                                                    |
|                 |                                                                                                                                                      |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|



|========================================================================================================================================================================|
|########################################################################################################################################################################|
|#################################################################### ENVIRONMENT VARIABLES SET #########################################################################|
|########################################################################################################################################################################|
|========================================================================================================================================================================|
|                                                                                                                                                                        |
|########################################################################################################################################################################|
|                                                                                                                                                                        |
| Bucket Name: ${BUCKET_NAME}                                                                                                                       |
| AWS Region:  ${AWS_REGION}                                                                                                                                                 |
| AWS ACCOUNT ID: ${AWS_ACCOUNT_ID}                                                                                                                                           |
|                                                                                                                                                                        |
|########################################################################################################################################################################|
|========================================================================================================================================================================|
"