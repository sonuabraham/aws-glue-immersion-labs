# transform_job.py
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from awsglue.utils import getResolvedOptions
import sys
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
customers = "data/customers.csv"
transactions = "data/transactions.csv"
cust_df = spark.read.option("header","true").option("inferSchema","true").csv(customers)
tx_df = spark.read.option("header","true").option("inferSchema","true").csv(transactions)
joined = tx_df.join(cust_df, on="customer_id", how="left")
agg = joined.groupBy("customer_id").sum("amount").withColumnRenamed("sum(amount)","total_spend")
agg.write.mode("overwrite").parquet("output/customer_totals")
