# AWS Cloud Data & Machine Learning

Two cloud-based data and machine learning projects built on AWS as part of *Large Scale Computing on the Cloud* (BU.330.740), JHU Carey Business School.

1. **VisionGuard**: a computer vision loss-prevention system on AWS Rekognition Custom Labels
2. **Distributed Text Analytics**: sentiment analysis on Amazon EMR (Hive) and a Spark ML spam classifier

---

## 1. VisionGuard — Self-Checkout Loss Prevention

A computer-vision pipeline that detects retail theft at self-checkout (barcode swapping and sweethearting) by comparing the item a camera detects against the item logged at the point of sale (POS). A mismatch flags the transaction for review.

### What it does
- Trains an **AWS Rekognition Custom Labels** model to classify grocery items
- Uses **Python (boto3)** to call the trained model on a checkout image, then compares the detected label against a POS log entry to flag matches vs. mismatches
- Stores images and evidence in **Amazon S3**

### Model results

| Metric | Score |
| --- | --- |
| F1 score | 1.000 |
| Precision | 1.000 |
| Recall | 1.000 |
| Training images | 2,092 (43 grocery categories) |
| Test images | 548 |
| Training time | 2.28 hours |
| Inference latency | < 1 second / image |

The model was trained on the publicly available [Grocery Store Dataset (Klasson et al.)](https://github.com/marcusklasson/GroceryStoreDataset).

### Architecture: built vs. designed
To be precise about scope, since this was a feasibility prototype:

- **Built and run:** the trained Rekognition Custom Labels model, and a boto3/Python script that runs detection on static test images and compares results against a simulated POS log to flag mismatches.
- **Designed (not deployed):** a production architecture in which Amazon Kinesis Video Streams ingests live kiosk video and an AWS Lambda function performs the label-vs-POS comparison and dispatches real-time alerts, with evidence written to S3. This streaming/serverless layer is the proposed design — it was not implemented in this prototype.

### Tech stack
AWS Rekognition Custom Labels · Amazon S3 · Python · boto3

### Files
- `VisionGuard_Demo.ipynb` : detection + POS-matching logic and test cases
- `VisionGuard_Report.pdf` : full implementation report (dataset, architecture, results)
- `results/evaluation.png` : Rekognition evaluation results

---

## 2. Distributed Text Analytics on AWS EMR

Two text-analytics tasks: a Hive sentiment pipeline running on a managed Spark/Hadoop cluster, and a Spark ML spam classifier.

### Part A — Hive sentiment analysis on Amazon EMR
- Deployed a **Hive** job on a multi-node **Amazon EMR** cluster
- Scored ~14,800 airline tweets read from **Amazon S3**, joining tokenized text against an 8,220-word polarity dictionary to classify each tweet as positive, negative, or neutral
- Wrote results back to S3 in ORC format

### Part B — Spark ML spam classifier
- Built a **PySpark ML pipeline** (`Tokenizer` -> `StopWordsRemover` -> `HashingTF` -> `LogisticRegression`) on a labeled SMS dataset (750 ham / 750 spam)

| Metric | Score |
| --- | --- |
| Accuracy | 87.41% |
| AUC | 0.9807 |

*Note: the Hive job ran on the EMR cluster; the PySpark classifier was run locally (`local[*]`) to demonstrate the framework and pipeline.*

### Tech stack
Amazon EMR · Apache Hive · PySpark (Spark ML) · Amazon S3 · Python

### Files
- `Lab2_Spark_Analysis.ipynb` : PySpark pipeline and analysis
- `tweetSent.q` : Hive sentiment query

---

## Skills demonstrated
Cloud ML (Rekognition Custom Labels) · Distributed processing (EMR, Hive, Spark) · Spark ML (TF/IDF features, logistic regression) · Python / boto3 · Data pipelines · Model evaluation (F1, precision/recall, AUC)
