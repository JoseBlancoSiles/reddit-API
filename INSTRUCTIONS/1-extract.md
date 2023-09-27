# Setup

In order to carry out the extraction process, and store the JSON response in the S3 bucket, crucial steps must be done before:

1. Get Reddit developer account
2. Get AWS account, can be free tier
3. Create a S3 bucket
4. Create identity provider 
5. Create an IAM role to trust GitHub OIDC
6. Clone and fork the repository. Add the Reddit credentials, the bucket name and region and the IAM role to GitHub secrets.

## Reddit developer account
First things first, in order to run the [python script](/EXTRACT/extract_reddit_posts.py) you will need to have a Reddit developer account you can get one [here](https://support.reddithelp.com/hc/en-us/requests/new?ticket_form_id=14868593862164)

Once you got your developer account, you will have 2 credentials:

![Alt text](/images/reddit-dev.png)

Save them as you will need them later.

## AWS account
If don't have one, you can register for one [here](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all)

## Create S3 bucket
Go to [aws s3](https://aws.amazon.com/free/?trk=8e8ce528-4bc8-47d6-b386-9a572866c6d1&sc_channel=ps&ef_id=Cj0KCQjwpc-oBhCGARIsAH6ote-V-CXcqYu1kvqeeva6UNqunD3To2nVQ_o5J2HkLyWc87w8j43GewMaAq8UEALw_wcB:G:s&s_kwcid=AL!4422!3!646065810184!e!!g!!aws%20s3!19610444393!149206261887&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all) and create the bucket. Save the bucket name and region, as it will be needed later.
## Identity provider
1. In AWS console go to [Identity and Access Managment](https://aws.amazon.com/iam/?trk=013d5b94-ef10-4e6a-9ce1-4af2a054e95c&sc_channel=ps&ef_id=Cj0KCQjwpc-oBhCGARIsAH6ote-bvRK3GZHzLI237l3hhF8O7Z7t3gLZjFT5l7FBSbgF6KSlhVS0HhIaAortEALw_wcB:G:s&s_kwcid=AL!4422!3!651510153348!e!!g!!amazon%20iam!19835787026!147297558939)
2. Go to Identity providers and add a new one
3. Add this configuration, use OpenID Connect:
   ![Alt text](/images/openID.png)

## IAM role trust role
1. In the IAM go to roles and create a new one
2. Introduce the following configuration:
![Alt text](/images/GitHub-trust-role.png)
3. Give the role AmazonS3FullAccess
4. Finally, in trust relationships edit them to have something like this:

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
                    "token.actions.githubusercontent.com:sub": "repo:JoseBlancoSiles/reddit-API:*"
                }
            }
        }
    ]
}
```
Note that I've replaced my real ARN IAM role by a fake 123456789, replace it with yours accordingly.

Good! We have setup the config in AWS, last step is to add those secrets in the GitHub repo!

## Setup GitHub secrets
1. clone the repo
```bash
git clone https://github.com/JoseBlancoSiles/reddit-API.git
```
2. After cloning the repo, create a fork of it, so you can pass your own credentials.
3. Go to repo settings --> Secrets and variables --> Actions
4. Create the variable names like in the picture:
   ![Alt text](/images/secrets.png)

Done! You can test the workflow modifying the [workflow yaml](.github\workflows\actions.yaml) to run on push:

![Alt text](/images/test-workflow.png)

Got to GitHub actions of the repo and yo should be seeing the steps of the workflow running!

Finally, check that in your bucket you got the reddit messages in a json format:

![Alt text](/images/json-response.png)

If experiecing some problems, try to run local the code, manually, passing the credentials, and start debugging from there.