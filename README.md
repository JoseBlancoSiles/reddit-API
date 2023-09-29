# Batch-Processing Data Pipeline for Reddit Post Categorization in AWS

## Architecture
![Alt text](/images/architecture.png)

## Motivation
The motivation behind this project stems from my desire to create a real-world data job scenario that seamlessly combines the realms of Data Engineering, DevOps, Data Science and Business Intelligence. Reddit, with its diverse range of questions and discussions, offers an intriguing starting point for exploration.

## Overview
The purpose of this automated ML pipeline is to classify into categories the questions that users of Reddit ask in [AskReddit](https://www.reddit.com/r/AskReddit/new/). The categories established have been the following ones:

```python
["money", "food", "job", "life", "music", "media", "movie", "sexual", "health", "kid", "game", "book", "tech", "relationships"]
```
To know more about why these categories, refer to [steps to label the dataset](/AWS/EC2/NLP-model/training/steps.md)
### Workflow

1. **GitHub Integration and Data Extraction**:
   - GitHub connects with an [IAM Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) that establishes trust using [OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).
   - An automated job in [GitHub Actions](https://github.com/features/actions), executed every 8 hours, employs a [Python script](/EXTRACT/extract_reddit_posts.py) to retrieve the latest 1000 messages from [AskReddit](https://www.reddit.com/r/AskReddit/new/).

2. **Data Storage and Event Trigger**:
   - The resulting JSON response is stored in raw format in the data lake [Amazon S3](https://aws.amazon.com/es/s3/)and triggers an event notification.
   - This notification, in turn, triggers a [lambda function](/AWS/lambda/lambda.py) that initiates a Dockerized EC2 instance.

3. **Automated Data Processing**:
   - Upon instance launch, a shell script in [User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) automatically initiates the production pipeline.
   - This pipeline performs data transformation and employs a trained model to predict the category of Reddit questions. The model training process can be explored [here](/AWS/EC2/NLP-model/training/model-trained-EC2.ipynb), and sample prediction results can be found [here](/AWS/EC2/NLP-model/testing/predictions-unseen.csv).

4. **Data Storage and Shutdown**:
   - After script completion, a Parquet file containing the dataset with predicted categories is sent to S3.
   - The EC2 instance is automatically stopped according to the [user data shell script](/AWS/EC2/user-data.sh).

5. **Data Warehousing**:
   - A scheduled query triggers the copying of the file from S3 to the staging table in Redshift.
   - Data is subsequently unloaded into the data warehouse schema.

6. **Data Visualization**:
   - The Quicksight dashboard dynamically updates with the new data.

## Tools & Technologies

- **Cloud Platform**: AWS (Amazon Web Services) - The cloud infrastructure used for hosting and running various components of the project.
  
- **Data Lake**: Amazon S3 - Serves as the data lake for storing JSON and Parquet files, facilitating scalable and efficient data storage.

- **Data Warehouse**: Amazon Redshift - Provides a powerful data warehousing solution for structured data storage and analysis.

- **Programming Languages**:
  - Python - Used for scripting and data manipulation.
  - SQL - Utilized for querying and managing data within the data warehouse.
  - Shell - Employed for automation and scripting tasks.

- **Framework**: Apache Spark - Enables distributed data processing for large-scale data transformations and analytics.

- **File Formats**: JSON, Parquet - Data is stored and processed in these formats, allowing for flexibility and efficiency in data handling.

- **Data Visualization**: Amazon Quicksight - Used for creating dynamic and interactive data visualizations to gain insights from the processed data.

- **Automation Tools**:
  - GitHub Actions - Automates various tasks, such as data extraction and processing, at scheduled intervals.
  - AWS Lambda - Executes functions in response to events, including triggering EC2 instances.
  - Event Notifications - Used for triggering processes based on events in S3.
  - Query Scheduler - Automates scheduled queries for data movement and transformation.

- **Machine Types**:
  - t2.2xlarge - An EC2 instance type used for processing tasks.
  - GitHub Machine - Dedicated machine for GitHub Actions and automation.

- **Operating System**: Ubuntu - The Linux distribution used for hosting and running project components.

## Requisites
- AWS account
- Reddit developer account
- GitHub account

## Sample output
![Alt text](/images/reddit-dashboard.JPG)

## Potential Improvements

While every project has room for enhancement, it's important to balance scope with available resources. Here are some potential areas for improvement in this project:

1. **Terraform Integration**: Consider implementing Terraform to manage your AWS infrastructure as code. This approach streamlines the deployment process, enhances reproducibility, and simplifies infrastructure sharing among team members. Terraform also automates the provisioning of AWS resources, reducing manual setup efforts.

2. **Increase Data Volume in Redshift**: Expanding the amount of data stored and processed in Amazon Redshift can lead to more comprehensive insights. If you were limited by the AWS free tier, consider optimizing your AWS cost management strategy to accommodate a larger dataset in Redshift. This could result in more robust data analysis and modeling.

3. **Clustered EMR for Spark**: To handle larger-scale data processing and analytics, you might transition to Amazon EMR (Elastic MapReduce) with a clustered configuration. EMR provides the scalability needed for processing big data efficiently. Migrating to EMR would allow you to analyze larger datasets with Apache Spark, potentially uncovering deeper insights and improving prediction accuracy.

## Conclusion

The development of this project proved to be both challenging and immensely fulfilling. It offered opportunities to reinforce existing skills and acquire new ones while achieving the goal of deploying a machine learning model into production and automating the entire pipeline. The journey was truly enjoyable.

In terms of results, the project successfully accomplished its primary objectives:
- Categorizing Reddit posts.
- Implementing a fully automated pipeline.
- Efficiently storing and presenting the results.

Should you wish to replicate this project, comprehensive instructions can be found in the [instructions section](/INSTRUCTIONS/). However, I'm more than happy to provide assistance should you encounter any difficulties. Please don't hesitate to reach out.