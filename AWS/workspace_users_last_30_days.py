# This Python script iterates through all of our WorkSpaces and returns a list of WorkSpace users that have not connected to their WorkSpace within the last 30 days.

import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):
    # Create an AWS WorkSpaces client
    workspaces_client = boto3.client('workspaces')

    # Retrieve the list of WorkSpaces
    workspaces_response = workspaces_client.describe_workspaces()

    # Calculate the timestamp for 30 days ago
    thirty_days_ago = datetime.now() - timedelta(days=30)

    # Iterate over the WorkSpaces and filter based on connection attempts
    workspaces_info = []
    for workspace in workspaces_response['Workspaces']:
        last_connection = workspace.get('LastKnownUserConnectionTimestamp')
        state = workspace['State']

        if (not last_connection or datetime.fromisoformat(last_connection) < thirty_days_ago) and state != 'AVAILABLE':
            workspace_id = workspace['WorkspaceId']
            username = workspace['UserName']
            workspaces_info.append({'WorkspaceId': workspace_id, 'UserName': username})

    # Return the Workspace IDs and Usernames as the output
    return {
        'statusCode': 200,
        'body': workspaces_info
    }
