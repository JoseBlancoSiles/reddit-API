import praw, os, json, boto3

# Functions
def api_connect():
  '''Create an instance reddit API'''
  try:
    instance = praw.Reddit(client_id=os.getenv("REDDIT_CLIENT_ID"), # Getting the environmental credentials from GitHub Secrets.
                          client_secret=os.getenv("REDDIT_SECRET_KEY"),
                          user_agent="MyBot")
    return instance
  except Exception as e:
    print("Unable to connect to Reddit API. Error:", e)

def get_last_message_time_from_s3():
  '''Load the time of the last message of the last batch ingestion'''
  try:
    s3 = boto3.client("s3")
    bucket_name = "reddit-project-jose1"
    key = "last_time_message.txt"
      
    response = s3.get_object(Bucket=bucket_name, Key=key)
    
    last_time_content = response["Body"].read().decode("utf-8") # Read the num from the txt file.
    last_message_previous_batch_time = float(last_time_content) # str --> float (epoch)
    
    return last_message_previous_batch_time
  
  except Exception as e:
      print("Error retrieving last message time from S3:", e)
      return None
    
def extract_format_posts(reddit_instance, last_message_previous_batch_time):
  '''Extract the posts based son subreddit, limit and fields. Extract the time of the newest post --> last that will be consumed'''
  SUBREDDIT = "AskReddit" # Subreddit for our business case
  LIMIT = 1000 # Max number of posts you can extract with praw library from reddit is 1000 each batch.
  EXCLUDED_FIELDS = ["subreddit", "author", "_reddit"]
  list_posts = [] # list to store all the posts
    
  try:
    subreddit = reddit_instance.subreddit(SUBREDDIT)
    submissions = list(subreddit.new(limit=LIMIT)) # Extract the 1000 newest submissions from --> r/AskReddit
    for submission in submissions:
      if submission.created_utc >= last_message_previous_batch_time: # Check if the post wasn't extracted already in the previous batch.
        submission_data = {}
        for key, value in vars(submission).items(): # Iterate over the fields of each post
          if key not in EXCLUDED_FIELDS:
            submission_data[key] = value
        list_posts.append(submission_data)
    formatted_posts = json.dumps(list_posts) # Create a list of dictionaries to store all the posts
    current_last_new_message_time = submissions[0].created_utc # As posts are sorted in posted time descending order, the first one will be the newest --> last post retrieved in this batch.
    
    return [formatted_posts, current_last_new_message_time] 
  
  except Exception as e:
    print("Error fetching subreddit posts:", e)
    
def last_message_time(current_last_new_message_time):
  '''Write the current_last_new_message_time into a txt file, will be temporary stored in --> GitHub Workspace and then pushed to S3 bucket when the script is over'''
  try:
    f = "last_time_message.txt"
    with open(f, "w") as file:
      file.write(str(current_last_new_message_time))
    return file

  except Exception as e:
    print("Error writing the time of the last message consumed:", e)
  
def put_posts_s3(formatted_posts):
  '''Connect to S3 bucket and upload the posts'''
  try:
    s3 = boto3.client("s3")
    bucket_name = "reddit-project-jose1"
    s3.put_object(Bucket=bucket_name, Key="reddit-posts.json", Body=formatted_posts)
    
  except Exception as e:
    print("Error uploading posts to S3:", e)
    
def main():
  '''Extract reddit posts and upload them to S3'''
  reddit_instance = api_connect() # instance of redditAPI
  last_message_previous_batch_time = get_last_message_time_from_s3() # Get the time of the last message of the previous batch
  formatted_posts = extract_format_posts(reddit_instance,last_message_previous_batch_time )
  posts = formatted_posts[0] # posts collected
  current_last_new_message_time = formatted_posts[1] # time of the last message collected
  last_message_txt = last_message_time(current_last_new_message_time)
  put_posts_s3(posts)


if __name__ == "__main__":
  main()