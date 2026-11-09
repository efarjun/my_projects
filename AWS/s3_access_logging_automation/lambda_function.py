"""
Lambda function: auto-enable S3 access logging on newly created buckets.

Trigger: EventBridge rule matching CloudTrail S3 CreateBucket events.
    source: aws.s3
    detail-type: AWS API Call via CloudTrail
    detail.eventName: CreateBucket

Behavior:
    - Reads the new bucket name from the EventBridge event.
    - Enables access logging on it, targeting LOG_TARGET_BUCKET.
    - Uses a target prefix of "<bucket-name>-logs/". S3 automatically
      appends the [YYYY]-[MM]-[DD]-[hh]-[mm]-[ss]-[UniqueString] suffix
      to each log object it writes, so we don't construct that part.

Required IAM permissions for this function's execution role:
    - s3:PutBucketLogging on the newly created bucket (i.e. "*", since
      bucket names aren't known ahead of time — scope via a bucket-name
      condition if you want to be stricter)
    - s3:GetBucketLogging on the newly created bucket (used for the
      idempotency check, so we don't overwrite an existing config)
    - logs:CreateLogGroup / CreateLogStream / PutLogEvents for CloudWatch

The target bucket (LOG_TARGET_BUCKET) must:
    - Exist already
    - Have S3 Log Delivery group write/put-object permissions
      (grantable via bucket ACL or bucket policy for the
      logging.s3.amazonaws.com service principal)
    - Be in the same AWS region as the source buckets
"""

import logging
import os

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")

# Central bucket that will receive access logs for all other buckets.
LOG_TARGET_BUCKET = os.environ["LOG_TARGET_BUCKET"]


def handler(event, context):
    """Entry point for the Lambda function."""

    bucket_name = extract_bucket_name(event)
    if not bucket_name:
        logger.error("Could not extract bucket name from event: %s", event)
        return {"status": "error", "reason": "bucket name not found in event"}

    # Don't try to log the log bucket to itself.
    if bucket_name == LOG_TARGET_BUCKET:
        logger.info("Skipping logging bucket itself: %s", bucket_name)
        return {"status": "skipped", "bucket": bucket_name}

    target_prefix = f"{bucket_name}-logs/"

    try:
        if is_logging_enabled(bucket_name):
            logger.info("Logging already enabled on '%s', skipping.", bucket_name)
            return {"status": "already_enabled", "bucket": bucket_name}

        enable_access_logging(bucket_name, target_prefix)
        logger.info(
            "Enabled access logging on '%s' -> s3://%s/%s",
            bucket_name,
            LOG_TARGET_BUCKET,
            target_prefix,
        )
        return {
            "status": "success",
            "bucket": bucket_name,
            "target_bucket": LOG_TARGET_BUCKET,
            "target_prefix": target_prefix,
        }
    except ClientError as e:
        logger.error("Failed to enable logging on '%s': %s", bucket_name, e)
        raise


def extract_bucket_name(event):
    """Pull the bucket name out of a CloudTrail CreateBucket event delivered via EventBridge."""

    try:
        detail = event["detail"]

        # Most reliable: bucketName in requestParameters
        bucket_name = detail.get("requestParameters", {}).get("bucketName")
        if bucket_name:
            return bucket_name

        # Fallback: some event shapes surface it in the ARN of the response/resources list
        for resource in detail.get("resources", []):
            arn = resource.get("ARN", "")
            if arn.startswith("arn:aws:s3:::"):
                return arn.replace("arn:aws:s3:::", "")

    except (KeyError, AttributeError):
        pass

    return None


def is_logging_enabled(bucket_name):
    """Return True if the bucket already has access logging configured."""

    response = s3.get_bucket_logging(Bucket=bucket_name)
    return "LoggingEnabled" in response


def enable_access_logging(bucket_name, target_prefix):
    """Enable S3 access logging on bucket_name, pointed at LOG_TARGET_BUCKET."""

    s3.put_bucket_logging(
        Bucket=bucket_name,
        BucketLoggingStatus={
            "LoggingEnabled": {
                "TargetBucket": LOG_TARGET_BUCKET,
                "TargetPrefix": target_prefix,
            }
        },
    )
