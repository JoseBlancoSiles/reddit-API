# Automated AWS Machine Learning pipeline to categorize Reddit posts

## Architecture
![Alt text](/images/architecture.png)

## Motivation
This is the technical implementation of my master's thesis in Data Science & Engineering. I really wanted to find a combination between Data Engineering, DevOps and Data Science, just like a real life data job project, so I though that Reddit data could be a good starting point. Besides, I always had te curiosity to know what were the kind of questions that pople ask in Reddit.

## Overview

The purpose of this automated ML pipeline is to classify into buckets  the questions that users of Reddit ask in [AskReddit](https://www.reddit.com/r/AskReddit/new/). Besides, 

### Workflow

1. GitHub connects with [IAM Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) that has trust of it thanks to [OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) and dynamically generates AWS credentials. Job is executed every 8 hours as automated in [GitHub actions](https://github.com/features/actions)
2. Python script consumes reddit API and get the latest 1000 messages in [AskReddit](https://www.reddit.com/r/AskReddit/new/), which is a subreddit where Redditors ask questions.
3. The JSON response object is stored in [Amazon S3](https://aws.amazon.com/es/s3/)
4. Once new data is loaded to the bucket, an event is generated that triggers a Lambda function.
5. Lambda function starts an EC2 instance.
6. When the instance launches, a shell script in [User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) automatically runs the production pipeline, which transforms and predicts the category of the reddit question, using the already trained model. You can have a look of the model training [here](/model-training/labeled-dataset/model-trained-EC2.ipynb). Besides you can have a look of a sample result with the predictions over unseen data [here](/model/testing/predictions-unseen.csv).
7. Once the script is finished, a parquet file with the predicted category is send to S3. EC2 automatically stops, as specified in the user data shell script.
8. Scheduled query triggers the COPY of the file from S3 to the staging table in Redshift. If everything is okay, data is unloaded to the data warehouse schema.
9. Quicksight dashboard is dynamically updated with the new data.

## Tools & Technologies
- Cloud - AWS
- Data Lake - S3
- Data Warehouse - Redshift
- Language - Python, SQL, Shell
- Framework - Apache Spark
- Files: JSON, Parquet
- Data Visualization - Quicksight
- Automation - GitHub actions, Lambda, Events, Query Scheduler
- Machines: t2.2xlarge, GitHub machine
- OS: Ubuntu

## Requisites
- AWS account
- Reddit developer account
- GitHub account

## Sample output
![Alt text](/images/reddit-dashboard.JPG)

## Improvement
No project is perfect, neither is mine. There is still a lot of room to improvement in this project, but eventually you need to reduce the scope of it. How can I make this better?

1. Terraform - It makes easier to deploy and share infraestructure as code. Besides, it automates the boring stuff of element creation in AWS.
2. More data in Redshift - Was limited due to AWS free tier.
3. Cluster EMR for Spark - Same reason as above.

## Conclusion
Developing this project was challenging but fullfilling. Reinforce and learn new techonologies, deploying a model to production and automating the whole pipeline was super enjoyable!

In terms of results, the products has acomplished the main points:
- Categorize reddit posts
- Automated pipeline
- Store and show the results

You should be able to reproduce the project if the [instructions section](/INSTRUCTIONS/) is followed. However, I'm more than happy to help if any trouble. Feel free to contact me.