# AWS File Processing Platform

## 1. Project Overview

This project is a serverless file processing platform built using AWS.

Users upload files to Amazon S3. The upload triggers an Ingest Lambda, which sends the file details to SQS. A Worker Lambda then reads and processes the file, stores the result in S3, and updates the file status in DynamoDB.

Terraform is used to create and manage the AWS infrastructure.

---

## 2. Architecture

The application follows this flow:

User
↓
S3 Input
↓
Ingest Lambda
↓
SQS Processing Queue
↓
Worker Lambda
↓
S3 Output
↓
DynamoDB Status

CloudWatch monitors Lambda and SQS activity.

---

## 3. AWS Services

The project uses:

- Amazon S3
- AWS Lambda
- Amazon SQS
- Amazon SQS Dead Letter Queue
- Amazon DynamoDB
- AWS IAM
- Amazon CloudWatch
- Terraform

---

## 4. Architecture Diagram

```text
                    User
                      |
                      v
                +-----------+
                |    S3     |
                |   input/  |
                +-----+-----+
                      |
                  S3 Event
                      |
                      v
                +-----------+
                |  Ingest   |
                |  Lambda   |
                +-----+-----+
                      |
                      v
                +-----------+
                |    SQS    |
                |  Queue    |
                +-----+-----+
                      |
                      v
                +-----------+
                |  Worker   |
                |  Lambda   |
                +-----+-----+
                      |
              +-------+--------+
              |                |
              v                v
         +---------+     +-------------+
         | S3      |     | DynamoDB    |
         | output/ |     | Status      |
         +---------+     +-------------+

                 CloudWatch
                     |
                     v
                 Monitoring