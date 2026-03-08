# Project 4.3: Taking the Data Warehouse to the Cloud (Snowflake & dbt)

## Business Context & Problem Statement
Project 4.2 successfully proved the data warehouse concept on a localized SQL Server instance. However, enterprise-scale analytics demands much more: the ability to scale compute power on demand, run concurrent queries without database lock contention, and, most importantly, maintain data transformations as version-controlled code rather than manually executed scripts.

In a traditional on-premise warehouse, adding a new financial report means a Database Administrator manually runs SQL scripts in the correct order, hopes the sequence hasn't been broken, and manually validates the final output. One single mistake, and bad data flows to the executive team without anyone noticing until a manager spots an incorrect number in a board meeting. 

This project completely eliminates that fragility by migrating the retail data warehouse into the Modern Data Stack. By treating data transformations as code—version-controlled in Git, automatically tested before deployment, and lineage-tracked across every table—we guarantee data trust at scale.

## Key Questions This Architecture Answers
* How does a retail business seamlessly integrate its disparate CRM and ERP data into a single, query-ready model in the cloud?
* How do you enforce data quality automatically, without relying on manual QA spot-checks?
* How does an analytics engineering team maintain and evolve complex transformation logic without breaking downstream reports?
* What does a production-grade, cloud-native data pipeline actually look like from raw ingestion to the final reporting layer?

![Cloud Data Architecture](assets/cloud-architecture.png) 

## The Three-Layer Cloud Architecture
* **Bronze (Raw):** Data is loaded from Google Cloud Platform (GCP) object storage into Snowflake via External Stages. There is absolutely no transformation at this step; it serves as an exact, immutable replica of the source systems for strict audit preservation.
* **Silver (Staging):** I engineered dbt models to standardize data types, strip legacy key prefixes, extract embedded category codes, and attach audit timestamps. These models are materialized as Snowflake `Views` to maintain a minimal storage footprint.
* **Gold (Marts):** I built a Kimball-style Star Schema. The `dim_customers` and `dim_products` models are constructed by joining the CRM and ERP staging models, utilizing `COALESCE` statements to intelligently handle legacy attribute gaps. The `fact_sales` model joins the transaction data strictly to surrogate keys. These models are materialized as Snowflake `Tables` for maximum BI query performance.

![dbt Lineage Graph](assets/dbt-lineage-graph.png)

## What Makes This Different: Data As Code
This is fundamentally different from a standard ETL build. Every single transformation is a `.sql` file committed in Git—fully version-controlled, peer-reviewable, and rollback-safe. 

Data quality is rigorously enforced via dbt YAML tests (`unique`, `not_null` on primary and foreign keys) that execute before any model is deployed. If a test fails, the build is blocked from reaching production. Additionally, data lineage is fully documented; dbt generates a visual DAG (Directed Acyclic Graph) showing exactly how every final table was constructed and exactly which source tables feed it.

![dbt Automated Testing Results](assets/dbt-test-results.png)

## Technical Workflow
* **Cloud Compute & Storage:** Snowflake, Google Cloud Platform (GCP)
* **Transformation & Orchestration:** dbt (Data Build Tool) Cloud
* **Version Control:** Git / GitHub
* **Techniques:** CTEs, Materialization Strategy (Views vs. Tables), Surrogate Key Generation, YAML Testing

### How to Run
1. Clone the repository and navigate to `04_data_modeling_and_storage/4_3_cloud_data_warehouse/`.
2. Review `dbt_project.yml` for materialization configurations.
3. Run `dbt deps` to install packages, followed by `dbt build` to execute the models and tests simultaneously.
4. Run `dbt docs generate` and `dbt docs serve` to view the interactive lineage graph and model documentation.