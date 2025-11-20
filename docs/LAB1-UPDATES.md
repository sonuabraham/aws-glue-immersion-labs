# Lab 1 Data Updates - Aligned with Official Workshop

## Changes Made

### File Names Updated
Based on the official AWS Glue Immersion Day workshop instructions, the Lab 1 data files have been renamed to match expectations:

**Before:**
- `sales_data_2023_01.csv`
- `sales_data_2023_02.csv`
- `sales_data_2023_01.json`

**After:**
- `sample.csv` (in csv folder)
- `sample.json` (in json folder)

### Why This Matters

The workshop instructions specifically reference:
```bash
head /project/glue-workshop/data/lab1/csv/sample.csv
```

This means the file MUST be named `sample.csv` for the workshop to work correctly.

## Data Schema

**Important:** Lab 1 uses DIFFERENT data in CSV and JSON files to demonstrate the crawler's ability to handle multiple data formats.

### CSV Data Schema (Sales Data)

| Column | Type | Description |
|--------|------|-------------|
| Region | String | Geographic region |
| Country | String | Country name |
| Item Type | String | Product category |
| Sales Channel | String | Online or Offline |
| Order Priority | String | H, M, L, or C |
| Order Date | String | Date of order |
| Order ID | String | Unique order identifier |
| Ship Date | String | Date of shipment |
| Units Sold | String | Number of units |
| Unit Price | String | Price per unit |
| Unit Cost | String | Cost per unit |
| Total Revenue | String | Total revenue |
| Total Cost | String | Total cost |
| Total Profit | String | Total profit |

**Note:** All numeric fields are stored as strings in the CSV. The Glue crawler will infer appropriate types.

### JSON Data Schema (COVID-19 Data)

| Column | Type | Description |
|--------|------|-------------|
| date | Integer | Date in YYYYMMDD format |
| state | String | US state code (CA, NY, TX, FL) |
| positive | Double | Cumulative positive cases |
| hospitalized | Double | Cumulative hospitalizations |
| death | Double | Cumulative deaths |
| total | Double | Total tests conducted |
| hash | String | Data integrity hash |
| datechecked | String | ISO timestamp |
| totaltestresults | Double | Total test results |
| flu | String | Flu data (usually empty) |
| positiveincrease | Double | Daily increase in positive cases |
| negativeincrease | Double | Daily increase in negative tests |
| totalresultsincrease | Double | Daily increase in total results |
| deathincrease | Double | Daily increase in deaths |
| hospitalizedincrease | Double | Daily increase in hospitalizations |

**Note:** The JSON data uses numeric types directly. The Glue crawler will infer these as double/bigint.

## Sample Data

### CSV Format (sample.csv) - Sales Data
```csv
Region,Country,Item Type,Sales Channel,Order Priority,Order Date,Order ID,Ship Date,Units Sold,Unit Price,Unit Cost,Total Revenue,Total Cost,Total Profit
Sub-Saharan Africa,Chad,Office Supplies,Online,L,1/27/2023,292494523,2/12/2023,4484,651.21,524.96,2920025.64,2353920.64,566105.00
Europe,Latvia,Beverages,Online,C,12/28/2022,361825549,1/23/2023,1075,47.45,31.79,51008.75,34174.25,16834.50
...
```

### JSON Format (sample.json) - COVID-19 Data
```json
{"date":20210315,"state":"CA","positive":3654402,"hospitalized":45203,"death":56146,"total":49646310,"hash":"7d3ca89203209e2a3d4b7c3f7b8e4c5d","datechecked":"2021-03-15T00:00:00Z","totaltestresults":49646310,"flu":"","positiveincrease":3816,"negativeincrease":112456,"totalresultsincrease":116272,"deathincrease":258,"hospitalizedincrease":0}
{"date":20210314,"state":"CA","positive":3650586,"hospitalized":45203,"death":55888,"total":49530038,"hash":"8e4db9a314310f3b4e5c8d4f8c9f5e6e","datechecked":"2021-03-14T00:00:00Z","totaltestresults":49530038,"flu":"","positiveincrease":4291,"negativeincrease":111456,"totalresultsincrease":115747,"deathincrease":215,"hospitalizedincrease":0}
...
```

**Note:** The workshop intentionally uses different data formats (sales CSV vs COVID JSON) to demonstrate:
1. The crawler's ability to handle multiple data sources
2. Different schema inference for different file formats
3. How the Data Catalog organizes heterogeneous data

## Workshop Flow

### Step 1: Create Database
Create a database named `console_glueworkshop` in AWS Glue Console.

### Step 2: Create Crawler
Create a crawler named `console-lab1` with:
- Two data sources:
  - `s3://${BUCKET_NAME}/input/lab1/csv/`
  - `s3://${BUCKET_NAME}/input/lab1/json/`
- IAM Role: `AWSGlueServiceRole-glueworkshop`
- Target Database: `console_glueworkshop`
- Table Prefix: `console_`

### Step 3: Run Crawler
The crawler will:
1. Scan both folders
2. Use built-in CSV and JSON classifiers
3. Infer schemas automatically
4. Create two tables:
   - `console_csv`
   - `console_json`

### Step 4: Query with Athena
Query the cataloged data using Athena to verify the schema and data.

## Expected Crawler Results

After running the crawler, you should see:

**Table: console_csv**
- Location: `s3://${BUCKET_NAME}/input/lab1/csv/`
- Format: CSV
- Columns: 14 columns matching the schema above
- Records: 10 rows

**Table: console_json**
- Location: `s3://${BUCKET_NAME}/input/lab1/json/`
- Format: JSON
- Columns: 17 columns (COVID-19 data fields)
- Records: 10 rows
- Data: COVID-19 testing statistics by state and date

## Verification Commands

```bash
# Verify files exist in S3
aws s3 ls s3://${BUCKET_NAME}/input/lab1/csv/sample.csv
aws s3 ls s3://${BUCKET_NAME}/input/lab1/json/sample.json

# View file contents
aws s3 cp s3://${BUCKET_NAME}/input/lab1/csv/sample.csv - | head
aws s3 cp s3://${BUCKET_NAME}/input/lab1/json/sample.json - | head -n 3

# Check crawler status
aws glue get-crawler --name console-lab1

# List created tables
aws glue get-tables --database-name console_glueworkshop

# Get table schema
aws glue get-table --database-name console_glueworkshop --name console_csv
aws glue get-table --database-name console_glueworkshop --name console_json
```

## Troubleshooting

### Crawler doesn't find files
- Ensure you selected the folder, not the file
- Verify S3 paths are correct
- Check IAM role has S3 read permissions

### Tables not appearing
- Click the refresh button in the Glue Console
- Verify the crawler completed successfully
- Check the crawler logs for errors

### Schema looks wrong
- The crawler infers types automatically
- Numeric fields stored as strings will be typed as string
- You can manually edit the schema if needed

## Next Steps

After completing Lab 1, you'll use these Data Catalog tables as sources for:
- Lab 2: ETL transformations
- Lab 3: Data quality checks
- Lab 4: Advanced transformations
- And more...

The Data Catalog tables created here will be referenced throughout the workshop.
