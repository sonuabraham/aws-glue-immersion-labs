#!/bin/bash

# Script to create glue-workshop.zip structure
# Run this on your laptop before running one-step-setup.sh

echo "Creating glue-workshop directory structure..."

# Create directory structure
mkdir -p glue-workshop/code
mkdir -p glue-workshop/data/lab1/csv
mkdir -p glue-workshop/data/lab1/json
mkdir -p glue-workshop/data/lab1/eventnotification
mkdir -p glue-workshop/data/lab2/pii
mkdir -p glue-workshop/data/lab2/state
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

# Create sample CSV data for lab1 (sample.csv as expected by workshop)
cat > glue-workshop/data/lab1/csv/sample.csv << 'EOF'
uuid,Country,Item Type,Sales Channel,Order Priority,Order Date,Region,Ship Date,Units Sold,Unit Price,Unit Cost,Total Revenue,Total Cost,Total Profit
292494523,Chad,Office Supplies,Online,L,1/27/2023,Sub-Saharan Africa,2/12/2023,4484,651.21,524.96,2920025.64,2353920.64,566105.00
361825549,Latvia,Beverages,Online,C,12/28/2022,Europe,1/23/2023,1075,47.45,31.79,51008.75,34174.25,16834.50
630627222,Ivory Coast,Baby Food,Offline,M,4/10/2023,Sub-Saharan Africa,5/4/2023,9841,255.28,159.42,2512595.48,1568806.22,943789.26
735752273,Mongolia,Cereal,Online,C,2/15/2023,Asia,3/10/2023,3716,205.70,117.11,764220.20,435176.76,329043.44
366638053,Senegal,Clothes,Offline,M,7/23/2023,Sub-Saharan Africa,8/20/2023,2397,109.28,35.84,261950.16,85908.48,176041.68
486449991,Denmark,Household,Offline,L,5/15/2023,Europe,6/19/2023,6989,668.27,502.54,4670101.03,3512252.06,1157848.97
926419347,Senegal,Household,Online,H,1/9/2023,Sub-Saharan Africa,2/7/2023,7293,668.27,502.54,4873863.11,3665022.22,1208840.89
116607876,Sri Lanka,Baby Food,Online,C,3/17/2023,Asia,4/27/2023,2974,255.28,159.42,759182.72,474142.08,285040.64
880811536,Burkina Faso,Vegetables,Offline,H,7/17/2023,Sub-Saharan Africa,8/28/2023,8933,154.06,90.93,1375909.98,812196.69,563713.29
203025907,Mongolia,Fruits,Offline,H,2/25/2023,Asia,4/5/2023,7332,9.33,6.92,68405.56,50729.44,17676.12
EOF

# Create sample JSON data for lab1 (COVID-19 data as per workshop)
cat > glue-workshop/data/lab1/json/sample.json << 'EOF'
{"date":20210315,"state":"CA","positive":3654402,"hospitalized":45203,"death":56146,"total":49646310,"hash":"7d3ca89203209e2a3d4b7c3f7b8e4c5d","datechecked":"2021-03-15T00:00:00Z","totaltestresults":49646310,"flu":"","positiveincrease":3816,"negativeincrease":112456,"totalresultsincrease":116272,"deathincrease":258,"hospitalizedincrease":0}
{"date":20210314,"state":"CA","positive":3650586,"hospitalized":45203,"death":55888,"total":49530038,"hash":"8e4db9a314310f3b4e5c8d4f8c9f5e6e","datechecked":"2021-03-14T00:00:00Z","totaltestresults":49530038,"flu":"","positiveincrease":4291,"negativeincrease":111456,"totalresultsincrease":115747,"deathincrease":215,"hospitalizedincrease":0}
{"date":20210313,"state":"CA","positive":3646295,"hospitalized":45203,"death":55673,"total":49414291,"hash":"9f5eca0425421g4c5f6d9e5g9d0g6f7f","datechecked":"2021-03-13T00:00:00Z","totaltestresults":49414291,"flu":"","positiveincrease":4515,"negativeincrease":108232,"totalresultsincrease":112747,"deathincrease":198,"hospitalizedincrease":0}
{"date":20210315,"state":"NY","positive":1820497,"hospitalized":85594,"death":49113,"total":39371453,"hash":"a0g6fd1536532h5d6g7e0f6h0e1h7g8g","datechecked":"2021-03-15T00:00:00Z","totaltestresults":39371453,"flu":"","positiveincrease":5902,"negativeincrease":145678,"totalresultsincrease":151580,"deathincrease":42,"hospitalizedincrease":0}
{"date":20210314,"state":"NY","positive":1814595,"hospitalized":85594,"death":49071,"total":39219873,"hash":"b1h7ge2647643i6e7h8f1g7i1f2i8h9h","datechecked":"2021-03-14T00:00:00Z","totaltestresults":39219873,"flu":"","positiveincrease":6234,"negativeincrease":142345,"totalresultsincrease":148579,"deathincrease":38,"hospitalizedincrease":0}
{"date":20210313,"state":"NY","positive":1808361,"hospitalized":85594,"death":49033,"total":39071294,"hash":"c2i8hf3758754j7f8i9g2h8j2g3j9i0i","datechecked":"2021-03-13T00:00:00Z","totaltestresults":39071294,"flu":"","positiveincrease":6789,"negativeincrease":138901,"totalresultsincrease":145690,"deathincrease":45,"hospitalizedincrease":0}
{"date":20210315,"state":"TX","positive":2738635,"hospitalized":null,"death":46151,"total":21738635,"hash":"d3j9ig4869865k8g9j0h3i9k3h4k0j1j","datechecked":"2021-03-15T00:00:00Z","totaltestresults":21738635,"flu":"","positiveincrease":3456,"negativeincrease":89234,"totalresultsincrease":92690,"deathincrease":156,"hospitalizedincrease":0}
{"date":20210314,"state":"TX","positive":2735179,"hospitalized":null,"death":45995,"total":21645945,"hash":"e4k0jh5970976l9h0k1i4j0l4i5l1k2k","datechecked":"2021-03-14T00:00:00Z","totaltestresults":21645945,"flu":"","positiveincrease":3678,"negativeincrease":86567,"totalresultsincrease":90245,"deathincrease":148,"hospitalizedincrease":0}
{"date":20210313,"state":"TX","positive":2731501,"hospitalized":null,"death":45847,"total":21555700,"hash":"f5l1ki6081087m0i1l2j5k1m5j6m2l3l","datechecked":"2021-03-13T00:00:00Z","totaltestresults":21555700,"flu":"","positiveincrease":3892,"negativeincrease":84353,"totalresultsincrease":88245,"deathincrease":142,"hospitalizedincrease":0}
{"date":20210315,"state":"FL","positive":1985475,"hospitalized":82053,"death":32629,"total":23985475,"hash":"g6m2lj7192198n1j2m3k6l2n6k7n3m4m","datechecked":"2021-03-15T00:00:00Z","totaltestresults":23985475,"flu":"","positiveincrease":4567,"negativeincrease":98765,"totalresultsincrease":103332,"deathincrease":89,"hospitalizedincrease":0}
EOF

# Create event notification folder README
cat > glue-workshop/data/lab1/eventnotification/README.md << 'EOF'
# Lab1 Event Notification

This folder is used for testing S3 event notifications with SQS.
Upload files here to trigger SQS notifications.
EOF

# Copy Lab 2 data from labs folder if it exists, otherwise skip
# Check both relative paths (from scripts/ and from root)
if [ -d "../labs/lab2/data" ]; then
    echo "Copying Lab 2 data from labs folder..."
    cp ../labs/lab2/data/customers.csv glue-workshop/data/lab2/ 2>/dev/null && echo "✓ Copied customers.csv" || echo "Note: customers.csv not found"
    cp ../labs/lab2/data/products.json glue-workshop/data/lab2/ 2>/dev/null && echo "✓ Copied products.json" || echo "Note: products.json not found"
elif [ -d "labs/lab2/data" ]; then
    echo "Copying Lab 2 data from labs folder..."
    cp labs/lab2/data/customers.csv glue-workshop/data/lab2/ 2>/dev/null && echo "✓ Copied customers.csv" || echo "Note: customers.csv not found"
    cp labs/lab2/data/products.json glue-workshop/data/lab2/ 2>/dev/null && echo "✓ Copied products.json" || echo "Note: products.json not found"
else
    echo "Note: labs/lab2/data folder not found. Lab 2 data will not be included."
    echo "You can add your own customers.csv and products.json to glue-workshop/data/lab2/"
fi

# Create Lab 2 PII data for redaction/hashing transformations
cat > glue-workshop/data/lab2/pii/customers_pii.csv << 'EOF'
customer_id,first_name,last_name,email,phone,ssn,credit_card,address,city,state,zip_code,date_of_birth,account_number
1001,John,Smith,john.smith@email.com,555-123-4567,123-45-6789,4532-1234-5678-9010,123 Main St,New York,NY,10001,1985-03-15,ACC1001
1002,Jane,Doe,jane.doe@email.com,555-234-5678,234-56-7890,5412-2345-6789-0123,456 Oak Ave,Los Angeles,CA,90001,1990-07-22,ACC1002
1003,Michael,Johnson,michael.j@email.com,555-345-6789,345-67-8901,4716-3456-7890-1234,789 Pine Rd,Chicago,IL,60601,1988-11-30,ACC1003
1004,Emily,Williams,emily.w@email.com,555-456-7890,456-78-9012,5312-4567-8901-2345,321 Elm St,Houston,TX,77001,1992-05-18,ACC1004
1005,David,Brown,david.brown@email.com,555-567-8901,567-89-0123,4916-5678-9012-3456,654 Maple Dr,Phoenix,AZ,85001,1987-09-25,ACC1005
1006,Sarah,Davis,sarah.d@email.com,555-678-9012,678-90-1234,5512-6789-0123-4567,987 Cedar Ln,Philadelphia,PA,19101,1991-12-08,ACC1006
1007,James,Miller,james.miller@email.com,555-789-0123,789-01-2345,4024-7890-1234-5678,147 Birch Ct,San Antonio,TX,78201,1986-04-14,ACC1007
1008,Lisa,Wilson,lisa.w@email.com,555-890-1234,890-12-3456,5112-8901-2345-6789,258 Spruce Way,San Diego,CA,92101,1993-08-27,ACC1008
1009,Robert,Moore,robert.m@email.com,555-901-2345,901-23-4567,4532-9012-3456-7890,369 Willow Pl,Dallas,TX,75201,1989-02-11,ACC1009
1010,Jennifer,Taylor,jennifer.t@email.com,555-012-3456,012-34-5678,5412-0123-4567-8901,741 Ash Blvd,San Jose,CA,95101,1994-06-19,ACC1010
EOF

# Create Lab 2 state data (US states for joins)
cat > glue-workshop/data/lab2/state/states.csv << 'EOF'
state_code,state_name,region,population
AL,Alabama,South,5024279
AK,Alaska,West,733391
AZ,Arizona,West,7151502
AR,Arkansas,South,3011524
CA,California,West,39538223
CO,Colorado,West,5773714
CT,Connecticut,Northeast,3605944
DE,Delaware,South,989948
FL,Florida,South,21538187
GA,Georgia,South,10711908
HI,Hawaii,West,1455271
ID,Idaho,West,1839106
IL,Illinois,Midwest,12812508
IN,Indiana,Midwest,6785528
IA,Iowa,Midwest,3190369
KS,Kansas,Midwest,2937880
KY,Kentucky,South,4505836
LA,Louisiana,South,4657757
ME,Maine,Northeast,1362359
MD,Maryland,South,6177224
MA,Massachusetts,Northeast,7029917
MI,Michigan,Midwest,10077331
MN,Minnesota,Midwest,5706494
MS,Mississippi,South,2961279
MO,Missouri,Midwest,6154913
MT,Montana,West,1084225
NE,Nebraska,Midwest,1961504
NV,Nevada,West,3104614
NH,New Hampshire,Northeast,1377529
NJ,New Jersey,Northeast,9288994
NM,New Mexico,West,2117522
NY,New York,Northeast,20201249
NC,North Carolina,South,10439388
ND,North Dakota,Midwest,779094
OH,Ohio,Midwest,11799448
OK,Oklahoma,South,3959353
OR,Oregon,West,4237256
PA,Pennsylvania,Northeast,13002700
RI,Rhode Island,Northeast,1097379
SC,South Carolina,South,5118425
SD,South Dakota,Midwest,886667
TN,Tennessee,South,6910840
TX,Texas,South,29145505
UT,Utah,West,3271616
VT,Vermont,Northeast,643077
VA,Virginia,South,8631393
WA,Washington,West,7705281
WV,West Virginia,South,1793716
WI,Wisconsin,Midwest,5893718
WY,Wyoming,West,576851
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
