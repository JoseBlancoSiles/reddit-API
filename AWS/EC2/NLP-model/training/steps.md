## Labeling a Raw Dataset

Labeling a dataset from scratch can be a challenging and time-consuming task, especially when dealing with a platform like Reddit where the nature of questions can be highly diverse and unpredictable. Fortunately, advanced clustering algorithms, such as [BERTopic](https://spacy.io/universe/project/bertopic), can greatly simplify this process.

### BERTopic - The Initial Clustering Approach

In this project, we utilized BERTopic, a powerful clustering algorithm, as demonstrated in [this notebook](category-clustering-BERTopic.ipynb). We trained BERTopic using an unlabeled dataset of Reddit posts sourced from the subreddit r/AskReddit on various days. The results of BERTopic clustering led to the creation of the following message clusters:

```json
{
   0: 'life',
   1: 'men',
   2: 'lie',
   3: 'kids',
   4: 'friend',
   5: 'food',
   6: 'song',
   7: 'money',
   8: 'would',
   9: 'job',
   10: 'subreddit',
   11: 'city',
   12: 'anxiety',
   13: 'movie',
   14: 'celebrity',
   15: 'old',
   16: 'sleep',
   17: 'phone',
   18: 'smell',
   19: 'say',
   20: 'fitness',
   21: 'habit',
   22: 'house',
   23: 'pet',
   24: 'medical',
   25: 'color',
   26: 'religion',
   27: 'death',
   28: 'law',
   29: 'gift',
   30: 'learn',
   31: 'book',
   32: 'karma',
   33: 'india',
   34: 'opinion',
   35: 'name',
   36: 'tip',
   37: 'shave',
   38: 'society'
}
```
### Adding Human Criteria to BERT Clusters
We've refined the scope of this phase, but BERT has played a pivotal role in defining our initial categories. Using both BERT's clustering results and human expertise, we've identified 14 categories that collectively account for more than 50% of Redditors' questions:

```python
TARGET_CLASSES = ["money", "food", "job", "life", "music", "media", "movie", "sexual", "health", "kid", "game", "book", "tech", "relationships"]
```

### Labeling the Dataset

The final step involves collecting a new sample of messages and labeling them based on the aforementioned categories. Approximately 50% of the messages may not neatly fit into any category and will be discarded. In the [production model](/AWS/EC2/production-pipeline.py), Reddit messages that don't fit into any of the categories (if they don't meet the threshold) are labeled as "other." Consequently, the Data Warehouse will contain up to 15 categories of posts.

It's crucial to emphasize the importance of a balanced dataset. In multiclass classification, a balanced dataset is indispensable for building fair, accurate, and generalizable models. It ensures equal learning from all classes, leading to improved overall performance and mitigating potential biases or discrimination in predictions.

Your explanation of the model training and its results is clear and informative. However, you can make a few minor adjustments for readability and clarity:

```python
print(df.groupby("topic_name").count())
```

## Dataset Distribution

The dataset's distribution across various topics is as follows:

- book: 113
- food: 139
- game: 127
- health: 145
- job: 142
- kid: 143
- life: 112
- media: 122
- money: 155
- movie: 141
- music: 118
- relationships: 140
- sexual: 152
- tech: 116

You can explore the dataset used for model training in detail [here](/AWS/EC2/NLP-model/training/labeled-training-dataset.csv). Feel free to use it for your own purposes!

## Model Training

In this project, various machine learning models were tested, including Random Forest, Naive Bayes, and Linear SVC. However, for brevity, we've included only the best-performing model, which turned out to be Multiclass Logistic Regression. If you're interested in learning more about the other models tested, feel free to reach out to me, although I've excluded them from this repository.

## Model Results

The Multiclass Logistic Regression model achieved an accuracy of approximately 65%, which is considered quite good in this context. It's important to note that since we assigned only one category per post, the model's performance may appear lower than expected in scenarios where questions could belong to multiple categories. For instance:

**Question**: "Do you need to eat fruit to be healthy?"

This question can reasonably fall into two categories: health and food. Therefore, the model's accuracy, which is above 65%, suggests a strong predictive capability, considering the inherent ambiguity in some questions.