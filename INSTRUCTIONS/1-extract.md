## Setup Instructions

### 1. Obtain a Reddit Developer Account

- To run the [Python script](/EXTRACT/extract_reddit_posts.py), you'll need a Reddit developer account. You can create one [here](https://support.reddithelp.com/hc/en-us/requests/new?ticket_form_id=14868593862164).

- Once you have your developer account, you'll receive two credentials, which you should save for later use.

![Alt text](/images/reddit-dev.png)

### 2. Set Up an AWS Account

- If you don't already have one, register for an AWS account [here](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all).

### 3. Create an S3 Bucket

- Visit the [AWS S3 dashboard](https://aws.amazon.com/s3/) and create a new S3 bucket. Make sure to note down the bucket name and region, as you'll need these details later.

### 4. Configure Identity Provider

1. Navigate to the [AWS Identity and Access Management (IAM) Console](https://aws.amazon.com/iam/).

2. In the IAM Console, go to "Identity providers" and add a new one.

3. Configure the identity provider using OpenID Connect.

![Alt text](/images/openID.png)

### 5. Create an IAM Role for GitHub OIDC

1. In the IAM Console, go to "Roles" and create a new role.

2. Configure the role with the necessary permissions, including AmazonS3FullAccess.

3. Edit the trust relationships to match the following JSON, replacing the example ARN with your own:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::123456789:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:YourGitHubUsername/YourRepoName:*"
                }
            }
        }
    ]
}
```

Make sure to replace "123456789" with your real ARN IAM role and adjust the "token.actions.githubusercontent.com:sub" condition as needed.

### 6. Add GitHub Secrets

1. Clone the repository:

```bash
git clone https://github.com/JoseBlancoSiles/reddit-API.git
```
2. Create a fork of the repository to customize it with your credentials.

3. Go to your forked repository's "Settings" --> "Secrets and variables" --> "Actions."

![Alt text](/images/secrets.png)

4. Create the required variables, following the naming conventions in the provided image.

Now, you're all set up to run the workflow! You can test it by modifying the [workflow YAML](../.github/workflows/actions.yaml) to run on push and checking the GitHub Actions for the workflow progress.

Finally, ensure that your S3 bucket contains the Reddit messages in JSON format.

These improvements make the setup instructions more organized and easy to follow for readers.