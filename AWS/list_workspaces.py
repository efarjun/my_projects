import boto3
from botocore.config import Config
import csv
import json
import os
from boto3.s3.transfer import TransferConfig

# Set up Boto3 session and configuration
config = Config(
    retries={
        'max_attempts': 10,
        'mode': 'standard'
    }
)

workspaces_client = boto3.client('workspaces', config=config)
sns_client = boto3.client('sns')

def list_all_workspaces():
    # Use boto3 collections to handle pagination seamlessly
    paginator = workspaces_client.get_paginator('describe_workspaces')
    page_iterator = paginator.paginate()

    workspaces_list = []

    # Iterate through all items from all pages
    for page in page_iterator:
        workspaces_list.extend([{
            'UserName': workspace['UserName'],
            'WorkspaceId': workspace['WorkspaceId'],
            'ComputerName': workspace['ComputerName'],
            'BundleId': workspace['BundleId'],
            'IpAddress': workspace['IpAddress']
        } for workspace in page['Workspaces']])

    return workspaces_list

def lambda_handler(event, context):
    try:
        # Get all workspaces
        workspaces = list_all_workspaces()

        # Convert workspaces data to JSON string
        message = json.dumps(workspaces, indent=4)

        # Publish the message to SNS Topic
        sns_topic_arn = 'arn:aws:sns:us-east-1:210800215573:current-workspace-list-topic'
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject='Workspace List Output'
        )

        # Print the output to the console
        print(message)

        return {
            'statusCode': 200,
            'body': 'Workspaces data sent to SNS successfully. Output printed to console.'
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
