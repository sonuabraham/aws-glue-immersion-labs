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
