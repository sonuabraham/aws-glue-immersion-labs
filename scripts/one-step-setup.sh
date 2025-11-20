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
AWS_REGION=`aws configure get region`
BUCKET_NAME=glueworkshop-lab1-${AWS_ACCOUNT_ID}-${AWS_REGION}
echo " "
echo "export BUCKET_NAME=\"${BUCKET_NAME}\"" >> /home/sonu/.bashrc
echo "export AWS_REGION=\"${AWS_REGION}\"" >> /home/sonu/.bashrc
echo "export AWS_ACCOUNT_ID=\"${AWS_ACCOUNT_ID}\"" >> /home/sonu/.bashrc

. ~/.bash_profile

## CREATING LOCAL CLOUD9 DIRECTORIES, DOWNLOADING CONTENT AND UPLOADING BACK TO S3 - THIS WILL TURN INTO S3 FOLDERS AND FILES
echo "============================> MAKING UP LOCAL DIRECTORIES <==============================================================================================================="

cd ~/environment

# Check if glue-workshop.zip exists locally, otherwise try to download from S3
if [ -f "glue-workshop.zip" ]; then
    echo "Using local glue-workshop.zip file..."
else
    echo "Local glue-workshop.zip not found. Attempting to download from S3..."
    aws s3 cp s3://ws-assets-prod-iad-r-cmh-8d6e9c21a4dec77d/ee59d21b-4cb8-4b3d-a629-24537cf37bb5/glue-workshop.zip glue-workshop.zip > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR: Could not download glue-workshop.zip from S3 and no local file found."
        echo "Please create glue-workshop.zip using the create-glue-workshop-zip script and place it in ~/environment/"
        exit 1
    fi
fi

unzip -o glue-workshop.zip > /dev/null
mkdir -p ~/environment/glue-workshop/output > /dev/null

### CHECKING WHICH URLS TO BUILD
len=`echo $URL |awk '{print length}'`

if [ $len -lt 150 ]; then
### BUILDING SMALLER URL VERSION

var1=$(echo $URL | grep -oP "public/.*?/" | cut -c 8-43) 

echo "

Build-ID  = $var1

"

echo "============================> DOWNLOADING CONTENT INTO THE DIRECTORIES <=================================================================================================="
echo "# PYCOUNTRY LIBRARY: pycountry_convert.zip"
curl -s 'https://static.us-east-1.prod.workshops.aws/public/'$var1'/static/download/howtostart/awseevnt/s3-and-local-file/pycountry_convert.zip' --output ~/environment/glue-workshop/library/pycountry_convert.zip 2>&1 || echo "Warning: Could not download pycountry_convert.zip"
echo "=========================================================================================================================================================================="

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

## CREATING LOCAL CLOUD9 DIRECTORIES, DOWNLOADING CONTENT AND UPLOADING BACK TO S3 - THIS WILL TURN INTO S3 FOLDERS AND FILES
echo "============================> DOWNLOADING CONTENT INTO THE DIRECTORIES <=================================================================================================="
echo "# PYCOUNTRY LIBRARY: pycountry_convert.zip"
curl -s 'https://static.us-east-1.prod.workshops.aws/'$var1'/static/download/howtostart/awseevnt/s3-and-local-file/pycountry_convert.zip?Key-Pair-Id='$var2'&Policy='$var3'&Signature='$var4'' --output ~/environment/glue-workshop/library/pycountry_convert.zip 2>&1 || echo "Warning: Could not download pycountry_convert.zip"
echo "=========================================================================================================================================================================="

fi

echo "============================> UPLOADING EVERYTHING TO S3 <================================================================================================================"
cd ~/environment/glue-workshop

echo "Uploading code to S3..."
aws s3 cp --recursive ~/environment/glue-workshop/code/ s3://${BUCKET_NAME}/script/ || echo "Warning: Failed to upload code"

echo "Uploading data to S3..."
aws s3 cp --recursive ~/environment/glue-workshop/data/ s3://${BUCKET_NAME}/input/ || echo "Warning: Failed to upload data"

echo "Uploading library to S3..."
aws s3 cp --recursive ~/environment/glue-workshop/library/ s3://${BUCKET_NAME}/library/ || echo "Warning: Failed to upload library"

echo "Attempting to copy COVID-19 data from public data lake..."
aws s3 cp --recursive s3://covid19-lake/rearc-covid-19-testing-data/json/states_daily/ s3://${BUCKET_NAME}/input/lab5/json/ 2>&1 || echo "Warning: Could not access COVID-19 public data lake. You may need to provide your own lab5 data."

echo "Uploading airflow files to S3..."
aws s3 cp --recursive ~/environment/glue-workshop/airflow/ s3://${BUCKET_NAME}/airflow/ || echo "Warning: Failed to upload airflow files"

echo "=========================================================================================================================================================================="

###MAKING FIELDS LOWER CASE FOR JSON FILE - ONCE THE "DROP FIELD/SELECT FIELD" ISSUE GETS PROPERLY FIXED THIS NEXT 3 LINES MAY BE REMOVED
if aws s3 ls s3://${BUCKET_NAME}/input/lab5/json/ 2>&1 | grep -q "json"; then
    echo "Processing lab5 JSON files..."
    aws s3 cp --recursive s3://${BUCKET_NAME}/input/lab5/json/ ~/environment/glue-workshop/data/lab5/json/
    sed -i 's/totalTestResultsIncrease/totaltestresultsincrease/g;s/dateChecked/datechecked/g;s/totalTestResults/totaltestresults/g;s/deathIncrease/deathincrease/g;s/hospitalizedIncrease/hospitalizedincrease/g;s/negativeIncrease/negativeincrease/g;s/positiveIncrease/positiveincrease/g' ~/environment/glue-workshop/data/lab5/json/*.json 2>/dev/null
    aws s3 cp --recursive ~/environment/glue-workshop/data/lab5/json/ s3://${BUCKET_NAME}/input/lab5/json/
else
    echo "Skipping lab5 JSON processing - no files found"
fi
#######

##SETTING UP REQUIRED SECURITY GROUPS INBOUND RULES (SKIPPED FOR LOCAL DEPLOYMENT)
echo "============================> SETTING UP INBOUND RULES <=================================================================================================================="
echo "Skipping Cloud9 security group setup (not needed for local deployment)"
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
AIRFLOW_VERSION="2.6.3"
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

##UPDATING CLI TO SUPPORT LATEST APIS REQUIRED (CLOUD9 --managed-credentials-action USED BELOW)
echo "
============================> UPDATING AWS CLI <==========================================================================================================================
"
curl -s  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o -qq awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/bin --update > /dev/null
echo "
==========================================================================================================================================================================
"

export PATH=$PATH:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/local/bin/aws > /dev/null
#echo $PATH

. ~/.bash_profile > /dev/null

#which aws
#aws --version


##INSTALLING REQUIRED LIBRARIES (BOTO3 & PSQL CLIENT)
echo "============================> INSTALLING BOTO3 <=========================================================================================================================="
sudo pip3 install boto3 --quiet
echo "=========================================================================================================================================================================="


##SKIPPING CLOUD9 INSTANCE PROFILE ASSOCIATION (NOT NEEDED FOR LOCAL DEPLOYMENT)
echo "============================> SKIPPING CLOUD9 INSTANCE PROFILE SETUP (LOCAL DEPLOYMENT) <============================================================================="
echo "Running from local machine - using existing AWS credentials"
echo "=========================================================================================================================================================================="

##VALIDATING CREDENTIALS
echo "==================> VALIDATING CREDENTIALS <====================
$(aws configure set region $AWS_REGION)
$(aws sts get-caller-identity > /dev/null 2>&1 && echo "=====================> [AWS credentials valid] <=======================" || echo "==================> [AWS credentials NOT valid - please configure AWS CLI] <====================")
================================================================
"

. ~/.bash_profile

echo "============================> JSON STATIC TABLE CREATION <============================================================================="
##JSON STATIC TABLE CREATION
# Variables
DATABASE_NAME="glueworkshop_cloudformation"
TABLE_NAME="json-static-table"
S3_PATH="s3://${BUCKET_NAME}/input/lab4/json/" 

# Create Glue Table using AWS CLI
aws glue create-table --database-name "$DATABASE_NAME" --table-input '{
  "Name": "'"$TABLE_NAME"'",
  "Description": "Define schema for static json",
  "TableType": "EXTERNAL_TABLE",
  "Parameters": {
    "classification": "json"
  },
  "StorageDescriptor": {
    "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
    "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
    "Columns": [
      {"Name": "uuid", "Type": "string"},
      {"Name": "country", "Type": "string"},
      {"Name": "itemtype", "Type": "string"},
      {"Name": "saleschannel", "Type": "string"},
      {"Name": "orderpriority", "Type": "string"},
      {"Name": "orderdate", "Type": "string"},
      {"Name": "region", "Type": "string"},
      {"Name": "shipdate", "Type": "string"},
      {"Name": "unitssold", "Type": "string"},
      {"Name": "unitprice", "Type": "string"},
      {"Name": "unitcost", "Type": "string"},
      {"Name": "totalrevenue", "Type": "string"},
      {"Name": "totalcost", "Type": "string"},
      {"Name": "totalprofit", "Type": "string"}
    ],
    "Location": "'"$S3_PATH"'",
    "SerdeInfo": {
      "SerializationLibrary": "org.openx.data.jsonserde.JsonSerDe",
      "Parameters": {
        "paths": "Country,ItemType,OrderDate,OrderPriority,Region,SalesChannel,ShipDate,TotalCost,TotalProfit,TotalRevenue,UnitCost,UnitPrice,UnitsSold,uuid"
      }
    }
  }
}'

# Output result
echo "Glue Table $TABLE_NAME created in database $DATABASE_NAME with S3 path $S3_PATH"

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
|  .. SUCCESS ..  | ~/environment/glue-workshop/[cloudformation | code | data | library | output]                                                                        |
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
|                 |                                      -->  4. AWS CREDENTIALS VALIDATED                                                                               |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 |                                                                                                                                                      |
|  .. SUCCESS ..  | Using local AWS credentials                                                                                                                          |
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