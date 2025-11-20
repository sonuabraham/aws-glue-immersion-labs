# Lab 1 Data Explanation

## Why Different Data Formats?

Lab 1 intentionally uses **different data** in CSV and JSON files. This is a pedagogical choice to demonstrate:

### 1. Multi-Source Crawling
The crawler scans two completely different data sources:
- **CSV**: Sales transaction data (e-commerce)
- **JSON**: COVID-19 testing statistics (public health)

This shows that a single crawler can catalog multiple, unrelated datasets.

### 2. Schema Inference
The Glue crawler automatically infers schemas for both:
- **CSV Schema**: 14 columns (Region, Country, Item Type, etc.)
- **JSON Schema**: 17 columns (date, state, positive, death, etc.)

This demonstrates the crawler's intelligence in handling different structures.

### 3. Data Catalog Organization
After crawling, you get two separate tables:
- `console_csv` - Sales data
- `console_json` - COVID-19 data

Each table has its own schema, location, and metadata.

## Data Sources

### CSV: Sales Data (sample.csv)
**Purpose**: Demonstrate CSV parsing and string-to-type conversion

**Sample Record:**
```csv
Region,Country,Item Type,Sales Channel,Order Priority,Order Date,Order ID,Ship Date,Units Sold,Unit Price,Unit Cost,Total Revenue,Total Cost,Total Profit
Sub-Saharan Africa,Chad,Office Supplies,Online,L,1/27/2023,292494523,2/12/2023,4484,651.21,524.96,2920025.64,2353920.64,566105.00
```

**Use Cases:**
- E-commerce analytics
- Sales reporting
- Revenue analysis
- Geographic distribution

### JSON: COVID-19 Data (sample.json)
**Purpose**: Demonstrate JSON parsing and nested data handling

**Sample Record:**
```json
{
  "date": 20210315,
  "state": "CA",
  "positive": 3654402,
  "hospitalized": 45203,
  "death": 56146,
  "total": 49646310,
  "positiveincrease": 3816,
  "deathincrease": 258
}
```

**Use Cases:**
- Public health monitoring
- Pandemic tracking
- Time-series analysis
- State-level comparisons

## Learning Objectives

### Objective 1: Understand Crawler Flexibility
A single crawler can handle:
- Multiple S3 paths
- Different file formats (CSV, JSON, Parquet, etc.)
- Different schemas
- Different data domains

### Objective 2: Schema Inference
The crawler automatically:
- Detects column names
- Infers data types (string, double, bigint, etc.)
- Handles null values
- Recognizes date formats

### Objective 3: Data Catalog Benefits
The Data Catalog provides:
- Centralized metadata
- Schema versioning
- Data discovery
- Query optimization for Athena

## Practical Implications

### For Real-World Projects

**Scenario 1: Multi-Department Data Lake**
- Marketing team: Customer data (CSV)
- Operations team: Logistics data (JSON)
- Finance team: Transaction data (Parquet)

One crawler can catalog all three!

**Scenario 2: Data Migration**
- Legacy system: CSV exports
- New system: JSON APIs
- Both need to be queryable

The crawler handles both formats seamlessly.

**Scenario 3: Third-Party Data**
- Vendor A: Provides CSV files
- Vendor B: Provides JSON files
- Your system: Needs unified access

The Data Catalog unifies them.

## Query Examples

### Querying Sales Data (CSV)
```sql
-- Top selling regions
SELECT region, 
       SUM(CAST(totalrevenue AS DOUBLE)) as revenue
FROM console_glueworkshop.console_csv
GROUP BY region
ORDER BY revenue DESC;
```

### Querying COVID Data (JSON)
```sql
-- States with highest positive cases
SELECT state,
       MAX(positive) as peak_cases,
       SUM(deathincrease) as total_deaths
FROM console_glueworkshop.console_json
GROUP BY state
ORDER BY peak_cases DESC;
```

### Cross-Table Analysis
```sql
-- Count records by source
SELECT 'Sales (CSV)' as source, COUNT(*) as records 
FROM console_glueworkshop.console_csv
UNION ALL
SELECT 'COVID (JSON)' as source, COUNT(*) as records 
FROM console_glueworkshop.console_json;
```

## Key Takeaways

1. **Flexibility**: Glue crawlers handle diverse data sources
2. **Automation**: Schema inference reduces manual work
3. **Scalability**: One crawler, multiple data sources
4. **Discoverability**: Data Catalog makes data findable
5. **Queryability**: Athena can query both tables immediately

## Next Steps

After Lab 1, you'll learn to:
- **Lab 2**: Transform data between formats
- **Lab 3**: Join data from multiple sources
- **Lab 4**: Handle complex nested structures
- **Lab 5**: Process streaming data
- **Lab 6+**: Advanced ETL patterns

The foundation you build in Lab 1 (understanding crawlers and the Data Catalog) is essential for all subsequent labs.

## Common Questions

**Q: Why not use the same data in both files?**
A: Using different data demonstrates real-world scenarios where you have heterogeneous data sources.

**Q: Can I use my own data?**
A: Yes! Replace the sample files with your own CSV and JSON data. The crawler will adapt.

**Q: What if my JSON has nested objects?**
A: The crawler handles nested structures. You'll see this in later labs.

**Q: Can I add more data sources?**
A: Absolutely! Add more S3 paths to the crawler configuration.

**Q: How does this scale?**
A: Crawlers can handle petabytes of data across thousands of files.

## Summary

Lab 1's use of different data formats (sales CSV + COVID JSON) is intentional and educational. It prepares you for real-world data engineering where you'll encounter:
- Multiple data sources
- Different formats
- Varying schemas
- Diverse business domains

The Glue crawler and Data Catalog make managing this complexity straightforward.
