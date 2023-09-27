# Import libraries

# sparkML
from pyspark.ml.feature import Tokenizer, StopWordsRemover, CountVectorizer, IDF, StringIndexer
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
from pyspark.ml.tuning import ParamGridBuilder, CrossValidator
from pyspark.ml.classification import LogisticRegression
from pyspark.ml import Pipeline, PipelineModel

# sparkSQL
from pyspark.sql.types import StringType, DoubleType, ArrayType, StructType
from pyspark.sql.functions import udf, col, when, from_unixtime
from pyspark.sql import SparkSession

# other
from sklearn.metrics import classification_report
from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords
import awswrangler as wr
import pandas as pd
import findspark
import pyarrow
import boto3
import nltk
import json
import csv

findspark.init()

# Download nltk functions --> Necessary to remove stopwords and more to get better accuracy in our NLP ML model
nltk.download("punkt")
nltk.download("stopwords")
nltk.download("wordnet")


# functions
def filter_out_nested_columns(df):
    '''Filter out columns with nested arrays or other nested structures from Spark Dataframe'''
    non_nested_columns = [column_name for column_name, column_data_type in df.dtypes
        if not isinstance(df.schema[column_name].dataType, (ArrayType, StructType))]

    non_nested_df = df.select(*non_nested_columns)

    return non_nested_df

def check_unique_values_in_column(column):
    '''Return the len of the unique values in a column'''
    try:
        unique_values = column.distinct().count()
        return unique_values > 1
    except Exception as e:
        return "error:", e

def preprocess_title(title):
    '''Remove stop words, tokenize and clean the data from the title column'''
    tokens = nltk.word_tokenize(title.lower(), language="english")
    tokens = [word for word in tokens if word.isalnum() and len(word) > 1]
    tokens = [lemmatizer.lemmatize(word, pos="v") for word in tokens if word not in stop_words]
    return ' '.join(tokens)

def max_probability(prob_list):
    '''Recieves a list of elements and returns the max. Each element represents the probability of the title to correspond to the category'''
    return float(max(prob_list))

def map_label_to_class(category):
    '''If label is different than "other" it will get the value of the k:v --> 0 : "money", 1 : "sexual"'''
    if category != "other":
        return label_to_class.get(float(category))
    else:
        return "other"

# Python dict to map the categories with their number representation:
label_to_class = {0: "money", 1: "sexual", 2: "health", 3: "kid", 4: "job", 5: "movies",6: "relationships",
                  7: "food",8: "videogame",9: "media",10: "music",11: "tech",12: "book",13: "life"}

# Start spark session based on the characteristics of your CPU to leverage it to the maximum.
spark = SparkSession.builder.appName("clean-dataset-label-title")

spark.config("spark.executor.cores", "4")  # Use all 4 available cores per executor
spark.config("spark.driver.cores", "1")  # Use 1 core for the driver
spark.config("spark.default.parallelism", "4")
spark.config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:3.3.4,org.apache.hadoop:hadoop-common:3.3.4")
spark.config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")

spark = spark.getOrCreate()

# If your EC2 instance has a role to read/write to S3, directly create the S3 client:
s3 = boto3.client("s3")
bucket_name = "reddit-project-jose1"
file_name = "reddit-posts.json"

# Download the file from S3 to a local variable
response = s3.get_object(Bucket=bucket_name, Key=file_name)
file_contents = response['Body'].read().decode('utf-8')
with open("./reddit-posts.json", "w") as json_file: # "w" --> overwrite every new batch
    json_file.write(file_contents)

df = spark.read.json("reddit-posts.json")


# Data Cleaning

# remove nested columns
non_nested_df = filter_out_nested_columns(df)

# Generate a list of columns that have more than 1 unique value or unhashable such as nested arrays
# columns_to_keep = [column for column in non_nested_df.columns if check_unique_values_in_column(non_nested_df.select(column))]
columns_to_keep = [
    "author_fullname",
    "author_premium",
    "created",
    "hide_score",
    "id",
    "link_flair_background_color",
    "link_flair_template_id",
    "link_flair_text",
    "link_flair_text_color",
    "link_flair_type",
    "no_follow",
    "num_comments",
    "num_crossposts",
    "over_18",
    "score",
    "send_replies",
    "spoiler",
    "ups",
    "upvote_ratio",
    "url",
    "title",
    "category"
]

# Filter the dataset with only interesting columns to be analyzed:
reddit_df_filtered = non_nested_df.select(*columns_to_keep)

# Create a copy of the column title, as we are going to tokenize the original
reddit_df_filtered_title = reddit_df_filtered.withColumn("original_title", reddit_df_filtered["title"])
# Create a 1 column dataframe to tokenize and predict the category
title = reddit_df_filtered.select("title")

# process the title for better accuracy:
stop_words = set(stopwords.words("english"))
lemmatizer = WordNetLemmatizer()

preprocess_title_udf = udf(preprocess_title, StringType())

reddit_df_filtered_title_processed = reddit_df_filtered_title.withColumn("title", preprocess_title_udf(title["title"]))


# Categorize posts based on title content
# Load the pretrained Machine Learning Model for multi class classification of the title posts:
model_path = "../model-training/trained-model"
labeling_model = PipelineModel.load(model_path)

reddit_df_filtered_title_processed_vectorized = labeling_model.transform(reddit_df_filtered_title_processed)

# define max probability udf --> Selects the most probable category for the title.
max_prob_udf = udf(max_probability, DoubleType())

reddit_df_filtered_title_processed_vectorized_max_prob = reddit_df_filtered_title_processed_vectorized.withColumn("max_probability", max_prob_udf(col("probability")))

map_label_udf = udf(map_label_to_class, StringType())
reddit_df_filtered_title_processed_vectorized_max_prob_category = reddit_df_filtered_title_processed_vectorized_max_prob.withColumn("category", when(reddit_df_filtered_title_processed_vectorized_max_prob["max_probability"] >= 0.3, \
                                            map_label_udf(reddit_df_filtered_title_processed_vectorized_max_prob["prediction"])).otherwise("other"))

# Finally, drop all the columns that have been generated for the category classification model and drop duplicated with different column name
# columns_to_drop = ["title", "words", "filtered_words", "raw_features", "features", "rawPrediction", "created_utc",
                   #"probability", "prediction", "max_probability", "permalink", "subreddit_subscribers", "name"]
columns_to_drop = ["title", "words", "filtered_words", "raw_features", "features", "rawPrediction", "probability", "prediction", "max_probability"]
df = reddit_df_filtered_title_processed_vectorized_max_prob_category.drop(*columns_to_drop)

# Rename original_title --> title
df = df.withColumnRenamed("original_title", "title")

# Cast created time from epoch --> timestamp
df = df.withColumn("created", from_unixtime(df["created"]).cast("string"))

# Write as parquet back to the S3
df.write.parquet("s3a://reddit-project-jose1/reddit-posts-categorized", mode="overwrite")

spark.stop()