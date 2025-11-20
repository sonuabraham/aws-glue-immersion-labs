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
- `sales_data_2023_01.csv` - 20 records
- `sales_data_2023_02.csv` - 20 records

### 2. JSON Data (`input/lab1/json/`)
Same sales data in JSON format (newline-delimited JSON).

**Files:**
- `sales_data_2023_01.json` - 10 records

### 3. Event Notification Folder (`input/lab1/eventnotification/`)
Empty folder configured with S3 event notifications to trigger SQS messages.

## Lab1 Exercises

### Exercise 1: Create a Crawler
1. Navigate to AWS Glue Console
2. Create a crawler to scan `s3://${BUCKET_NAME}/input/lab1/csv/`
3. Run the crawler to populate the Data Catalog

```bash
# Create crawler via CLI
aws glue create-crawler \
  --name lab1-csv-crawler \
  --role AWSGlueServiceRole-glueworkshop \
  --database-name glueworkshop_cloudformation \
  --targets '{"S3Targets":[{"Path":"s3://'${BUCKET_NAME}'/input/lab1/csv/"}]}' \
  --table-prefix lab1_csv_

# Start the crawler
aws glue start-crawler --name lab1-csv-crawler
```

### Exercise 2: Query Data with Athena
Once the crawler completes, query the data:

```sql
SELECT region, country, item_type, 
       SUM(CAST(total_revenue AS DOUBLE)) as total_revenue,
       SUM(CAST(total_profit AS DOUBLE)) as total_profit
FROM glueworkshop_cloudformation.lab1_csv_sales_data_2023_01
GROUP BY region, country, item_type
ORDER BY total_revenue DESC
LIMIT 10;
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

# Count records in CSV
aws s3 cp s3://${BUCKET_NAME}/input/lab1/csv/sales_data_2023_01.csv - | wc -l
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
