import json
import os
import boto3
from datetime import datetime, timezone

s3 = boto3.client("s3")
dynamodb = boto3.client("dynamodb")

OUTPUT_PREFIX = "output/"
TABLE_NAME = os.environ["TABLE_NAME"]


def now():
    return datetime.now(timezone.utc).isoformat()


def lambda_handler(event, context):
    for record in event["Records"]:
        message = json.loads(record["body"])

        file_id = message["file_id"]
        file_name = message["file_name"]
        bucket = message["bucket"]
        key = message["key"]

        try:
            # Read input file from S3
            response = s3.get_object(
                Bucket=bucket,
                Key=key
            )

            file_data = response["Body"].read()
            text = file_data.decode("utf-8")

            # Process file
            character_count = len(text)
            word_count = len(text.split())

            output_file_name = file_name.rsplit(".", 1)[0] + "-result.txt"
            output_key = f"{OUTPUT_PREFIX}{output_file_name}"

            # Create result content
            result = f"""Processing completed.

File:
{file_name}

Characters:
{character_count}

Words:
{word_count}

Status:
COMPLETED
"""

            # Write result to S3
            s3.put_object(
                Bucket=bucket,
                Key=output_key,
                Body=result.encode("utf-8"),
                ContentType="text/plain"
            )

            # Update DynamoDB with COMPLETED status
            dynamodb.update_item(
                TableName=TABLE_NAME,
                Key={
                    "file_id": {"S": file_id}
                },
                UpdateExpression="""
                    SET #status = :status,
                        output_key = :output_key,
                        characters = :characters,
                        words = :words,
                        completed_at = :completed_at
                """,
                ExpressionAttributeNames={
                    "#status": "status"
                },
                ExpressionAttributeValues={
                    ":status": {"S": "COMPLETED"},
                    ":output_key": {"S": output_key},
                    ":characters": {"N": str(character_count)},
                    ":words": {"N": str(word_count)},
                    ":completed_at": {"S": now()}
                }
            )

            print(f"Processed file: {key}")
            print(f"Output file: {output_key}")
            print(f"Characters: {character_count}")
            print(f"Words: {word_count}")
            print("Status: COMPLETED")

        except Exception as error:

            # Update DynamoDB with FAILED status
            dynamodb.update_item(
                TableName=TABLE_NAME,
                Key={
                    "file_id": {"S": file_id}
                },
                UpdateExpression="""
                    SET #status = :status,
                        error_message = :error_message
                """,
                ExpressionAttributeNames={
                    "#status": "status"
                },
                ExpressionAttributeValues={
                    ":status": {"S": "FAILED"},
                    ":error_message": {"S": str(error)}
                }
            )

            print(f"Processing failed: {error}")

            # Raise error so SQS retry/DLQ can work
            raise

    return {
        "statusCode": 200,
        "body": "Processing completed"
    }