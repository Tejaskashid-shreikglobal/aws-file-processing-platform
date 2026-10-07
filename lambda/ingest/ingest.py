import json
import os
import boto3
from datetime import datetime, timezone

sqs = boto3.client("sqs")
dynamodb = boto3.client("dynamodb")

QUEUE_URL = os.environ["QUEUE_URL"]
TABLE_NAME = os.environ["TABLE_NAME"]


def now():
    return datetime.now(timezone.utc).isoformat()


def lambda_handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        file_id = key.split("/")[-1]
        file_name = file_id
        created_at = now()

        # 1. File uploaded
        dynamodb.put_item(
            TableName=TABLE_NAME,
            Item={
                "file_id": {"S": file_id},
                "file_name": {"S": file_name},
                "status": {"S": "UPLOADED"},
                "created_at": {"S": created_at}
            }
        )

        # 2. File processing started
        dynamodb.update_item(
            TableName=TABLE_NAME,
            Key={
                "file_id": {"S": file_id}
            },
            UpdateExpression="SET #status = :status",
            ExpressionAttributeNames={
                "#status": "status"
            },
            ExpressionAttributeValues={
                ":status": {"S": "PROCESSING"}
            }
        )

        # 3. Send message to SQS
        message = {
            "file_id": file_id,
            "file_name": file_name,
            "bucket": bucket,
            "key": key,
            "status": "PROCESSING"
        }

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message)
        )

        print(f"File uploaded: s3://{bucket}/{key}")
        print(f"File status: PROCESSING")

    return {
        "statusCode": 200,
        "body": "File sent for processing"
    }