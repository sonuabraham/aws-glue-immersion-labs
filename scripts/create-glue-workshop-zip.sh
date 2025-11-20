#!/bin/bash

# Script to create glue-workshop.zip structure
# Run this on your laptop before running one-step-setup.sh

echo "Creating glue-workshop directory structure..."

# Create directory structure
mkdir -p glue-workshop/code
mkdir -p glue-workshop/data/lab1/csv
mkdir -p glue-workshop/data/lab1/json
mkdir -p glue-workshop/data/lab1/eventnotification
mkdir -p glue-workshop/data/lab4/json
mkdir -p glue-workshop/data/lab5/json
mkdir -p glue-workshop/library
mkdir -p glue-workshop/airflow/dags
mkdir -p glue-workshop/airflow/plugins
mkdir -p glue-workshop/airflow/requirements
mkdir -p glue-workshop/output

# Create sample Glue script
cat > glue-workshop/code/sample_etl.py << 'EOF'
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

# Your ETL logic here

job.commit()
EOF

# Create sample CSV data for lab1
cat > glue-workshop/data/lab1/csv/sales_data_2023_01.csv << 'EOF'
Region,Country,Item Type,Sales Channel,Order Priority,Order Date,Order ID,Ship Date,Units Sold,Unit Price,Unit Cost,Total Revenue,Total Cost,Total Profit
Sub-Saharan Africa,Chad,Office Supplies,Online,L,1/27/2023,292494523,2/12/2023,4484,651.21,524.96,2920025.64,2353920.64,566105.00
Europe,Latvia,Beverages,Online,C,12/28/2022,361825549,1/23/2023,1075,47.45,31.79,51008.75,34174.25,16834.50
Sub-Saharan Africa,Ivory Coast,Baby Food,Offline,M,4/10/2023,630627222,5/4/2023,9841,255.28,159.42,2512595.48,1568806.22,943789.26
Asia,Mongolia,Cereal,Online,C,2/15/2023,735752273,3/10/2023,3716,205.70,117.11,764220.20,435176.76,329043.44
Sub-Saharan Africa,Senegal,Clothes,Offline,M,7/23/2023,366638053,8/20/2023,2397,109.28,35.84,261950.16,85908.48,176041.68
EOF

# Create sample JSON data for lab1
cat > glue-workshop/data/lab1/json/sales_data_2023_01.json << 'EOF'
{"region":"Sub-Saharan Africa","country":"Chad","itemType":"Office Supplies","salesChannel":"Online","orderPriority":"L","orderDate":"1/27/2023","orderId":"292494523","shipDate":"2/12/2023","unitsSold":"4484","unitPrice":"651.21","unitCost":"524.96","totalRevenue":"2920025.64","totalCost":"2353920.64","totalProfit":"566105.00"}
{"region":"Europe","country":"Latvia","itemType":"Beverages","salesChannel":"Online","orderPriority":"C","orderDate":"12/28/2022","orderId":"361825549","shipDate":"1/23/2023","unitsSold":"1075","unitPrice":"47.45","unitCost":"31.79","totalRevenue":"51008.75","totalCost":"34174.25","totalProfit":"16834.50"}
{"region":"Sub-Saharan Africa","country":"Ivory Coast","itemType":"Baby Food","salesChannel":"Offline","orderPriority":"M","orderDate":"4/10/2023","orderId":"630627222","shipDate":"5/4/2023","unitsSold":"9841","unitPrice":"255.28","unitCost":"159.42","totalRevenue":"2512595.48","totalCost":"1568806.22","totalProfit":"943789.26"}
EOF

# Create event notification folder README
cat > glue-workshop/data/lab1/eventnotification/README.md << 'EOF'
# Lab1 Event Notification

This folder is used for testing S3 event notifications with SQS.
Upload files here to trigger SQS notifications.
EOF

# Create sample JSON data for lab4
cat > glue-workshop/data/lab4/json/sample_data.json << 'EOF'
{"uuid":"001","country":"USA","itemtype":"Office Supplies","saleschannel":"Online","orderpriority":"H","orderdate":"2023-01-15","region":"North America","shipdate":"2023-01-20","unitssold":"100","unitprice":"15.50","unitcost":"10.00","totalrevenue":"1550.00","totalcost":"1000.00","totalprofit":"550.00"}
{"uuid":"002","country":"Canada","itemtype":"Electronics","saleschannel":"Offline","orderpriority":"M","orderdate":"2023-01-16","region":"North America","shipdate":"2023-01-22","unitssold":"50","unitprice":"250.00","unitcost":"180.00","totalrevenue":"12500.00","totalcost":"9000.00","totalprofit":"3500.00"}
EOF

# Create sample COVID-19 data for lab5 (since public data lake is not accessible)
cat > glue-workshop/data/lab5/json/sample_covid_data.json << 'EOF'
{"date":20210101,"state":"CA","positive":2500000,"negative":15000000,"pending":1000,"hospitalizedCurrently":15000,"hospitalizedCumulative":125000,"inIcuCurrently":3500,"inIcuCumulative":25000,"onVentilatorCurrently":1200,"onVentilatorCumulative":8000,"recovered":2000000,"dataQualityGrade":"A","lastUpdateEt":"1/1/2021 00:00","dateModified":"2021-01-01T00:00:00Z","checkTimeEt":"1/1/2021 00:00","death":25000,"hospitalized":125000,"datechecked":"2021-01-01T00:00:00Z","totaltestresults":17500000,"totaltestresultsincrease":50000,"positiveincrease":25000,"negativeincrease":25000,"deathincrease":250,"hospitalizedincrease":500,"hash":"abc123","commercialScore":0,"negativeRegularScore":0,"negativeScore":0,"positiveScore":0,"score":0,"grade":""}
{"date":20210102,"state":"CA","positive":2525000,"negative":15025000,"pending":1000,"hospitalizedCurrently":15200,"hospitalizedCumulative":125500,"inIcuCurrently":3550,"inIcuCumulative":25100,"onVentilatorCurrently":1220,"onVentilatorCumulative":8050,"recovered":2020000,"dataQualityGrade":"A","lastUpdateEt":"1/2/2021 00:00","dateModified":"2021-01-02T00:00:00Z","checkTimeEt":"1/2/2021 00:00","death":25250,"hospitalized":125500,"datechecked":"2021-01-02T00:00:00Z","totaltestresults":17550000,"totaltestresultsincrease":50000,"positiveincrease":25000,"negativeincrease":25000,"deathincrease":250,"hospitalizedincrease":500,"hash":"def456","commercialScore":0,"negativeRegularScore":0,"negativeScore":0,"positiveScore":0,"score":0,"grade":""}
{"date":20210101,"state":"NY","positive":1200000,"negative":8000000,"pending":500,"hospitalizedCurrently":8000,"hospitalizedCumulative":75000,"inIcuCurrently":2000,"inIcuCumulative":15000,"onVentilatorCurrently":800,"onVentilatorCumulative":5000,"recovered":1000000,"dataQualityGrade":"A","lastUpdateEt":"1/1/2021 00:00","dateModified":"2021-01-01T00:00:00Z","checkTimeEt":"1/1/2021 00:00","death":35000,"hospitalized":75000,"datechecked":"2021-01-01T00:00:00Z","totaltestresults":9200000,"totaltestresultsincrease":30000,"positiveincrease":15000,"negativeincrease":15000,"deathincrease":150,"hospitalizedincrease":300,"hash":"ghi789","commercialScore":0,"negativeRegularScore":0,"negativeScore":0,"positiveScore":0,"score":0,"grade":""}
{"date":20210102,"state":"NY","positive":1215000,"negative":8015000,"pending":500,"hospitalizedCurrently":8100,"hospitalizedCumulative":75300,"inIcuCurrently":2020,"inIcuCumulative":15050,"onVentilatorCurrently":810,"onVentilatorCumulative":5025,"recovered":1010000,"dataQualityGrade":"A","lastUpdateEt":"1/2/2021 00:00","dateModified":"2021-01-02T00:00:00Z","checkTimeEt":"1/2/2021 00:00","death":35150,"hospitalized":75300,"datechecked":"2021-01-02T00:00:00Z","totaltestresults":9230000,"totaltestresultsincrease":30000,"positiveincrease":15000,"negativeincrease":15000,"deathincrease":150,"hospitalizedincrease":300,"hash":"jkl012","commercialScore":0,"negativeRegularScore":0,"negativeScore":0,"positiveScore":0,"score":0,"grade":""}
{"date":20210101,"state":"TX","positive":1800000,"negative":10000000,"pending":800,"hospitalizedCurrently":12000,"hospitalizedCumulative":95000,"inIcuCurrently":2800,"inIcuCumulative":18000,"onVentilatorCurrently":1000,"onVentilatorCumulative":6000,"recovered":1500000,"dataQualityGrade":"B","lastUpdateEt":"1/1/2021 00:00","dateModified":"2021-01-01T00:00:00Z","checkTimeEt":"1/1/2021 00:00","death":28000,"hospitalized":95000,"datechecked":"2021-01-01T00:00:00Z","totaltestresults":11800000,"totaltestresultsincrease":40000,"positiveincrease":20000,"negativeincrease":20000,"deathincrease":200,"hospitalizedincrease":400,"hash":"mno345","commercialScore":0,"negativeRegularScore":0,"negativeScore":0,"positiveScore":0,"score":0,"grade":""}
{"date":20210102,"state":"TX","positive":1820000,"negative":10020000,"pending":800,"hospitalizedCurrently":12200,"hospitalizedCumulative":95400,"inIcuCurrently":2850,"inIcuCumulative":18080,"onVentilatorCurrently":1020,"onVentilatorCumulative":6040,"recovered":1520000,"dataQualityGrade":"B","lastUpdateEt":"1/2/2021 00:00","dateModified":"2021-01-02T00:00:00Z","checkTimeEt":"1/2/2021 00:00","death":28200,"hospitalized":95400,"datechecked":"2021-01-02T00:00:00Z","totaltestresults":11840000,"totaltestresultsincrease":40000,"positiveincrease":20000,"negativeincrease":20000,"deathincrease":200,"hospitalizedincrease":400,"hash":"pqr678","commercialScore":0,"negativeRegularScore":0,"negativeScore":0,"positiveScore":0,"score":0,"grade":""}
EOF

# Create Airflow requirements
cat > glue-workshop/airflow/requirements/requirements.txt << 'EOF'
apache-airflow-providers-amazon>=8.0.0
boto3>=1.26.0
EOF

# Create sample Airflow DAG
cat > glue-workshop/airflow/dags/sample_glue_dag.py << 'EOF'
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'sample_glue_workflow',
    default_args=default_args,
    description='Sample Glue ETL workflow',
    schedule_interval=timedelta(days=1),
)

run_glue_job = GlueJobOperator(
    task_id='run_sample_etl',
    job_name='sample_etl_job',
    dag=dag,
)
EOF

# Create placeholder for plugins (if you have awsairflowlib_222.zip, place it here)
echo "# Place awsairflowlib_222.zip in this directory if available" > glue-workshop/airflow/plugins/README.md

# Create README
cat > glue-workshop/README.md << 'EOF'
# Glue Workshop Files

This structure is compatible with the one-step-setup.sh script.

## Directories:
- **code/**: Glue ETL scripts
- **data/**: Input data files for labs
- **library/**: Python libraries (pycountry_convert.zip will be downloaded)
- **airflow/**: MWAA configuration and DAGs
- **output/**: Output directory for processed data

## Usage:
1. Add your Glue scripts to code/
2. Add your data files to data/lab4/json/ and data/lab5/json/
3. Customize airflow/dags/ with your workflows
4. Zip this directory: `zip -r glue-workshop.zip glue-workshop/`
5. Run one-step-setup.sh with the workshop URL
EOF

echo ""
echo "✓ Directory structure created successfully!"
echo ""
echo "Next steps:"
echo "1. Review and customize the files in glue-workshop/"
echo "2. Add your own Glue scripts to glue-workshop/code/"
echo "3. Add your data files to glue-workshop/data/"
echo "4. Create the zip file:"
echo "   zip -r glue-workshop.zip glue-workshop/"
echo ""
echo "Then you can use glue-workshop.zip with your setup script."
