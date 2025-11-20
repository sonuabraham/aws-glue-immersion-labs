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
