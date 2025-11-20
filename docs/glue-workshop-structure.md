# Glue Workshop Structure

Create this directory structure locally, then zip it as `glue-workshop.zip`:

```
glue-workshop/
├── code/
│   └── (your Glue ETL scripts - .py files)
├── data/
│   ├── lab4/
│   │   └── json/
│   │       └── (sample JSON data files)
│   └── lab5/
│       └── json/
│           └── (will be populated from COVID-19 lake)
├── library/
│   └── (pycountry_convert.zip will be downloaded here)
├── airflow/
│   ├── dags/
│   │   └── (your Airflow DAG files - .py)
│   ├── plugins/
│   │   └── awsairflowlib_222.zip
│   └── requirements/
│       └── requirements.txt
└── output/
    └── (empty - created by script)
```

## Minimal Files Needed

### airflow/requirements/requirements.txt
```
apache-airflow-providers-amazon
boto3
```

### Sample data/lab4/json/sample.json
```json
{
  "uuid": "sample-001",
  "country": "USA",
  "itemtype": "Office Supplies",
  "saleschannel": "Online",
  "orderpriority": "H",
  "orderdate": "2023-01-15",
  "region": "North America",
  "shipdate": "2023-01-20",
  "unitssold": "100",
  "unitprice": "15.50",
  "unitcost": "10.00",
  "totalrevenue": "1550.00",
  "totalcost": "1000.00",
  "totalprofit": "550.00"
}
```
