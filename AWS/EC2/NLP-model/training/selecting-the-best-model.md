
# Natural Laguage Processing (NLP) in Reddit Post Classification
![Alt text](../images/nlp.png)
 To achieve accurate and efficient Reddit post classification, Natural Language Processing (NLP) techniques are indispensable. NLP enables machines to understand and process human language, making it possible to analyze and categorize posts based on their textual content. NLP techniques such as tokenization, word embeddings, and text vectorization play a pivotal role in converting raw text data into a format suitable for machine learning models.

Now that we grabbed the idea of how the computer understand human words, let's dive into the selection of the model that best suits our needs.

## Machine Learning
On of the most important fields in machine learning is the field of prediction. So, based on an input, the computer is able to predict the output based on patterns and data which it has been trained.
In our case, we are trying to predict what category has a question recently placed by a user in the subreddit [r/AskReddit](https://www.reddit.com/r/AskReddit/new/). 

3 main challenges:
1. **Multiclass**: The category of a post, is not binary classification, as users post multiple different kind of questions.
2. **No labeled data**: Although the redditAPI provides a complete response about each post in Reddit
3. **Large number of categories**: As you can imagine, the classification of the Reddit questions, can be so diverse. However, for this case of study, we are keeping only the 14 most relative ones, that represent like 50% of the total.

### Multiclass classification models
Therefore, we need to use a model which allows multiclass classification. Apache Spark ecosystem includes [sparkML](https://spark.apache.org/docs/2.2.0/ml-classification-regression.html) which has very powerful models to achieve our objetive. 5 of this models have been trained and tested [here](../model-training/sparkML-multiclass-classification-models/). Feel free to reach out to that folder and check the results for each model. In my case, I've chosen the [Multinomial Logistic Regression](https://spark.apache.org/docs/2.2.0/ml-classification-regression.html#multinomial-logistic-regression) as the accuracy and precision was really good and the implementation is easier. You can try other models for your use case.

### Absence of labeled data
In order to train and test our Machine Learning model, we need a labeled dataset, which contains, for each post, the category of it. Unfortunately, there is no label for the category in the [redditAPI](https://www.reddit.com/dev/api/) response, so we had to manually label our [labeled training dataset](../model-training/labeled-dataset/labeled-training-dataset.csv). 

### Large number of categories

The categories of Redditor's questions, can be as big as the imagination of them. Howerver, using 14 categories more than 50% of the questions can be categorized. Refer to [Labeling raw dataset](../model-training/labeled-dataset/steps.md) to obtain more information about the specified categories.

 ## Why SparkML
 
![Alt text](../images/sparkML.png)

1. **Scalability:** PySpark ML is well-known for its scalability. It allows for distributed computing, which means it can efficiently handle large datasets and complex machine learning tasks. In the context of classifying Reddit posts, where the volume of data is massive, PySpark ML can distribute the computation across multiple nodes, making it possible to process and classify posts efficiently.

2. **Integration with Big Data Tools:** PySpark ML seamlessly integrates with other components of the Apache Spark ecosystem, which is designed for big data processing. This integration ensures that you can leverage the full power of Spark, including tools for data preprocessing, feature engineering, and distributed computing, in conjunction with PySpark ML for machine learning tasks.

3. **Ease of Use:** Despite its scalability, PySpark ML offers a user-friendly API, making it accessible to data scientists and machine learning practitioners. The framework simplifies the process of building, training, and evaluating machine learning models on large-scale datasets, which is crucial for projects like Reddit post classification.

4. **Multiclass Classification Support:** PySpark ML provides robust support for multiclass classification, making it an appropriate choice for projects that involve categorizing data into multiple classes or categories. In the case of Reddit post classification, where posts can belong to various subreddits or categories, this is particularly beneficial.

5. **Community and Documentation:** PySpark has a thriving community and extensive documentation. This means that there is a wealth of resources, tutorials, and support available for those working with PySpark ML. When implementing a machine learning project at scale, having access to a supportive community can be invaluable.

## Why Multinomial Logistic Regression

1. **Simplicity and Interpretability:** Logistic Regression is a straightforward algorithm that is easy to understand and interpret. This simplicity makes it a suitable choice for initial experimentation and model prototyping. When dealing with complex data like Reddit post titles, starting with a simple model can provide valuable insights.

2. **Efficiency:** Logistic Regression is computationally efficient, especially when compared to more complex algorithms like deep neural networks. Given the vast amount of Reddit data, efficiency is crucial for real-time or near-real-time classification, which Logistic Regression can provide.

3. **Scalability:** Logistic Regression can scale well, especially when implemented within PySpark ML. It can take advantage of distributed computing resources, making it capable of handling the computational demands of training a large-scale model on Reddit post titles.

4. **Multiclass Classification Support:** Logistic Regression can be adapted for multiclass classification tasks. In the context of Reddit post classification, where posts can belong to multiple categories or subreddits, this makes Logistic Regression a practical choice.

5. **Regularization:** Logistic Regression also offers regularization techniques like L1 and L2 regularization, which help prevent overfitting and improve the model's generalization capabilities. This is important when dealing with noisy and diverse text data, as seen in Reddit post titles.

Refer to [Trained Models](../model-training/sparkML-multiclass-classification-models) to see the performance of other tested models such us Random Forest, Naive Bayes and more.


