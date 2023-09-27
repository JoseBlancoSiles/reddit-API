# Labeling a raw dataset
Labeling a dataset from scratch can be challenging and time consuming.
Firstly, there is no idea of what kind of questions do Redditors ask on the web. Thankfully, the existence of really powerful clustering algortithms such as [BERTOPIC](https://spacy.io/universe/project/bertopic) make the things much easier for us.

### BERTopic --> Initial clustering idea
BERTopic has been used in this [notebook](category-clustering-BERTopic.ipynb) trained with this [dataset](raw-dataset-reddit.csv) which contains unlabeled Reddit posts in the subreddit r/AskReddit from various days. The BERTopic produced the followin clusters of messages:
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
### Adding human criteria to the BERT clusters
The scope of this one has been reduced. However, BERT did a really good job defining some categories, drawing the first line for ours. Based on the clusters made by BERT and human eye experience, the following 14 categories represent more than 50% of the Redditor's questions:
```python
TARGET_CLASSES = ["money", "food", "job", "life", "music", "media", "movie", "sexual", "health", "kid", "game", "book", "tech", "relationships"]
```
### Labeling a dataset
The last step is to collect a new sample of messages and label them, based on the above categories. There would be, aproximately, a 50% of messages that would not really fill in any bucket, and those messages will be discarded. In the [production model](../production-model/production-MLR.ipynb) the Reddit messages that doesn't fit in any of the buckets (if doesn't get to the threshold) --> they are labeled as "other". So, actually, in the Data Warehouse we will find up to 15 categories of posts. 
It's important that the labeled dataset is balanced. Having a balanced dataset in multiclass classification is essential for building fair, accurate, and generalizable models. It ensures that the model learns from all classes equally, leading to better overall performance and preventing potential biases or discrimination in predictions.

```python
print(df.groupby("topic_name").count())
```
topic_name
book             113
food             139
game             127
health           145
job              142
kid              143
life             112
media            122
money            155
movie            141
music            118
relationships    140
sexual           152
tech             116

[Here](/model-training/labeled-dataset/labeled-training-dataset.csv) you can have a look to the dataset used to train the model. Feel free to use it for your case!

## Training the ML model

For this project, different ML models have been tested like Random forest, naive-bayes, linear SVC... The training and test of all the models is outside of the scope of this repository, therefore only the one that performed the best, which resulted to be the Multiclass Logistic Regression, is included. However, feel free to reach out to me if ever want to know more about the other models, I'll keep them in the gitignore.

### Results of the model
The results of the model were about a 65% accuracy, which can be low in some scenarios, but in this one is actually quite good. Here is why. As I decided to assign only one category per post, sometimes, the nature of the question is ambiguos, i.e.:

"Do you need to eat fruit to be healthy"?

That question is clearly falling into 2 buckets: health, food.

So we can be sure that the model will predict with more than 65% the category of the incoming posts. 