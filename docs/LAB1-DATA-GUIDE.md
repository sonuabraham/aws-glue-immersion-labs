# Lab1 Data Setup Guide

## Overview
Lab1 typically covers AWS Glue basics including crawlers, data catalog, and ETL jobs using sample sales data.

## Data Created

### 1. CSV Data (`input/lab1/csv/`)
Sample sales data in CSV format with the following schema:
- Region
- Country
- Item Type
- Sales Channel
- Order Priority
- Order Date
- Order ID
- Ship Date
- Units Sold
- Unit Price
- Unit Cost
- Total Revenue
- Total Cost
- Total Profit

**Files:**
- `sample.csv` - 10 records (as expected by the workshop)

### 2. JSON Data (`input/lab1/json/`)
COVID-19 testing data in JSON format (newline-delimited JSON).

**Schema:**
- date (integer) - Date in YYYYMMDD format
- state (string) - US state code
- positive (double) - Positive test results
- hospitalized (double) - Hospitalized count
- death (double) - Death count
- total (double) - Total tests
- hash (string) - Data hash
- datechecked (string) - Timestamp
- totaltestresults (double) - Total test results
- flu (string) - Flu data
- positiveincrease (double) - Daily positive increase
- negativeincrease (double) - Daily negative increase
- totalresultsincrease (double) - Daily total increase
- deathincrease (double) - Daily death increase
- hospitalizedincrease (double) - Daily hospitalization increase

**Files:**
- `sample.json` - 10 records of COVID-19 data

### 3. Event Notification Folder (`input/lab1/eventnotification/`)
Empty folder configured with S3 event notifications to trigger SQS messages.

## Lab1 Exercises (From Official Workshop)

### Prerequisites
View the sample data:
```bash
head ~/environment/glue-workshop/data/lab1/csv/sample.csv
```

### Exercise 1: Create a Database
1. Go to AWS Glue Console → Databases
2. You should see `glueworkshop_cloudformation` (created by CloudFormation)
3. Click "Add Database"
4. Name it `console_glueworkshop`
5. Click "Create Database"

### Exercise 2: Create a Crawler
1. Go to AWS Glue Console → Crawlers
2. Click "Create Crawler"
3. Name it `console-lab1`
4. Click "Next"

**Add Data Sources:**
5. Click "Add a data source"
6. Browse to `s3://${BUCKET_NAME}/input/lab1/csv/` (pick the folder, not the file)
7. Click "Add an S3 data source"
8. Click "Add a data source" again
9. Browse to `s3://${BUCKET_NAME}/input/lab1/json/` (pick the folder, not the file)
10. Click "Next"

**Configure IAM Role:**
11. Choose existing IAM role: `AWSGlueServiceRole-glueworkshop`
12. Click "Next"

**Set Output:**
13. Target database: `console_glueworkshop`
14. Table name prefix: `console_` (optional)
15. Crawler schedule: On demand
16. Click "Next"

**Review and Create:**
17. Review all parameters
18. Click "Create crawler"

### Exercise 3: Run the Crawler
1. On the crawler details page, click "Run crawler"
2. Wait 1-2 minutes for completion
3. The crawler will use built-in CSV and JSON classifiers to infer schemas

### Exercise 4: View Catalog Tables
1. Go to AWS Glue Console → Tables
2. You should see two new tables:
   - `console_csv` - from the CSV data
   - `console_json` - from the JSON data
3. Click on each table to view the auto-generated schema

**CLI Alternative:**
```bash
# Create crawler via CLI
aws glue create-crawler \
  --name console-lab1 \
  --role AWSGlueServiceRole-glueworkshop \
  --database-name console_glueworkshop \
  --targets '{"S3Targets":[{"Path":"s3://'${BUCKET_NAME}'/input/lab1/csv/"},{"Path":"s3://'${BUCKET_NAME}'/input/lab1/json/"}]}' \
  --table-prefix console_

# Start the crawler
aws glue start-crawler --name console-lab1

# Check crawler status
aws glue get-crawler --name console-lab1 --query 'Crawler.State'
```

### Exercise 5: Query Data with Athena
Once the crawler completes, query the cataloged data:

```sql
-- Query CSV table (Sales Data)
SELECT region, country, itemtype, 
       CAST(totalrevenue AS DOUBLE) as total_revenue,
       CAST(totalprofit AS DOUBLE) as total_profit
FROM console_glueworkshop.console_csv
ORDER BY total_revenue DESC
LIMIT 10;

-- Query JSON table (COVID-19 Data)
SELECT date, state, 
       positive, death, hospitalized,
       positiveincrease, deathincrease
FROM console_glueworkshop.console_json
ORDER BY positive DESC
LIMIT 10;

-- Count records in each table
SELECT 'CSV (Sales)' as source, COUNT(*) as record_count FROM console_glueworkshop.console_csv
UNION ALL
SELECT 'JSON (COVID)' as source, COUNT(*) as record_count FROM console_glueworkshop.console_json;

-- Analyze COVID data by state
SELECT state,
       SUM(positiveincrease) as total_positive_increase,
       SUM(deathincrease) as total_death_increase
FROM console_glueworkshop.console_json
GROUP BY state
ORDER BY total_positive_increase DESC;
```

### Exercise 3: Create a Glue ETL Job
Transform CSV to Parquet format:

```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read from Data Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database = "glueworkshop_cloudformation",
    table_name = "lab1_csv_sales_data_2023_01"
)

# Write to S3 in Parquet format
glueContext.write_dynamic_frame.from_options(
    frame = datasource,
    connection_type = "s3",
    connection_options = {
        "path": "s3://" + args['BUCKET_NAME'] + "/output/lab1/parquet/"
    },
    format = "parquet"
)

job.commit()
```

### Exercise 4: Test S3 Event Notifications
Upload a file to trigger SQS notification:

```bash
# Create a test file
echo "test,data,123" > test.csv

# Upload to event notification folder
aws s3 cp test.csv s3://${BUCKET_NAME}/input/lab1/eventnotification/test.csv

# Check SQS queue for message
QUEUE_URL=$(aws sqs get-queue-url --queue-name glueworkshop-lab1-event-queue --query 'QueueUrl' --output text)
aws sqs receive-message --queue-url $QUEUE_URL --max-number-of-messages 1
```

## Verify Data Upload

After running the setup script, verify data was uploaded:

```bash
# List CSV files
aws s3 ls s3://${BUCKET_NAME}/input/lab1/csv/

# List JSON files
aws s3 ls s3://${BUCKET_NAME}/input/lab1/json/

# View CSV content
aws s3 cp s3://${BUCKET_NAME}/input/lab1/csv/sample.csv - | head

# Count records in CSV (should be 11 lines: 1 header + 10 data rows)
aws s3 cp s3://${BUCKET_NAME}/input/lab1/csv/sample.csv - | wc -l

# View JSON content
aws s3 cp s3://${BUCKET_NAME}/input/lab1/json/sample.json - | head
```

## Common Lab1 Tasks

### Create a Glue Database
```bash
aws glue create-database \
  --database-input '{"Name":"lab1_database","Description":"Lab1 practice database"}'
```

### Create a Table Manually
```bash
aws glue create-table \
  --database-name lab1_database \
  --table-input file://table-definition.json
```

### Run a Crawler
```bash
aws glue start-crawler --name lab1-csv-crawler
aws glue get-crawler --name lab1-csv-crawler
```

### Query with Athena
```bash
aws athena start-query-execution \
  --query-string "SELECT * FROM lab1_csv_sales_data_2023_01 LIMIT 10" \
  --result-configuration "OutputLocation=s3://${BUCKET_NAME}/athena-results/" \
  --query-execution-context "Database=glueworkshop_cloudformation"
```

## Troubleshooting

### Crawler Not Finding Data
- Verify S3 path is correct
- Check IAM role has S3 read permissions
- Ensure data files are not empty

### Athena Query Fails
- Verify table exists in Data Catalog
- Check S3 bucket permissions
- Ensure Athena result location is configured

### SQS Not Receiving Messages
- Verify S3 event notification is configured
- Check SQS queue policy allows S3 to send messages
- Ensure you're uploading to the correct S3 path

## Additional Resources

The data structure matches common AWS Glue workshop patterns and can be used for:
- Learning Glue Crawlers
- Understanding Data Catalog
- Writing ETL jobs
- Testing S3 event-driven workflows
- Practicing Athena queries
- Exploring data transformations
