# Redshift
In my case, as using free-tier, I've used the [Amazon Redshift Serverless](https://aws.amazon.com/redshift/redshift-serverless/).

1. Create workgroup
2. Create a database and name it reddit
3. Create run the [DDL commands](/AWS/redshift/table-definitions.sql) to create Staging table, dim_author, dim_date and fact_posts tables.
4. Automate the [scheduled unload script](/AWS/redshift/scheduled-unload.sql) to periodically unload data from s3 to --> staging table --> Redshift.

Done. Periodically our Redshift schema will have new data, and, of course, will preserve the old one!