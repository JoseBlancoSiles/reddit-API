# Natural Laguage Processing (NLP) in Reddit Post Classification
 To achieve accurate and efficient Reddit post classification, Natural Language Processing (NLP) techniques are indispensable. NLP enables machines to understand and process human language, making it possible to analyze and categorize posts based on their textual content. NLP techniques such as tokenization, word embeddings, and text vectorization play a pivotal role in converting raw text data into a format suitable for machine learning models.

Now that we grabbed the idea of how the computer understand human words, let's dive into the selection of the model that best suits our needs.

## Machine Learning Challenges

In the field of machine learning, one of the most significant endeavors is prediction. This involves leveraging patterns and training data to enable a computer to forecast outcomes based on given inputs. In our specific case, we aim to predict the category of a question recently posted by a user in the subreddit [r/AskReddit](https://www.reddit.com/r/AskReddit/new/).

### Key Challenges

1. **Multiclass Classification**: Unlike binary classification, where an item is categorized into one of two classes, our task involves multiclass classification. Users on Reddit post a wide variety of questions spanning numerous categories.

2. **Lack of Labeled Data**: Despite the wealth of information available via the Reddit API, obtaining labeled data for training is challenging. Labeling each post manually is impractical due to the vast volume of content. This requires innovative approaches, such as utilizing clustering algorithms and human expertise, to assign labels to posts effectively.

3. **Diverse Categories**: Reddit is known for its diversity in question topics. However, for this specific study, we've focused on a subset of the most relevant categories, approximately 14, which collectively account for a significant portion of the content (around 50%).

By addressing these challenges, we aim to build an effective machine learning model capable of accurately categorizing a broad spectrum of Reddit questions.

### Multiclass Classification Models

For multiclass classification, the Apache Spark ecosystem offers a powerful solution through [sparkML](https://spark.apache.org/docs/2.2.0/ml-classification-regression.html). In my case, I opted for [Multinomial Logistic Regression](https://spark.apache.org/docs/2.2.0/ml-classification-regression.html#multinomial-logistic-regression) due to its excellent accuracy and precision, as well as its ease of implementation. However, you can experiment with other models to suit your specific use case.

### Absence of Labeled Data

To train and test our machine learning model, we required a labeled dataset that associates each Reddit post with its corresponding category. Unfortunately, the [redditAPI](https://www.reddit.com/dev/api/) response does not include category labels. Consequently, we manually labeled our [labeled training dataset](/AWS/EC2/NLP-model/training/labeled-training-dataset.csv).

### Handling a Large Number of Categories

The range of categories in Redditors' questions is virtually boundless, limited only by their imagination. However, for our study, we focused on 14 categories, which collectively account for more than 50% of the questions. For detailed information about these categories, refer to the [Labeling raw dataset](./steps.md) section.


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