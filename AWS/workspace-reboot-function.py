# This function will reboot all workspaces concurrently.

import boto3
from botocore.config import Config
import concurrent.futures
import time

config = Config(
    retries={
        'max_attempts': 10,
        'mode': 'standard'
    }
)

workspaceClient = boto3.client('workspaces', region_name='us-east-1', config=config)

def reboot_workspace(workspace_id):
    try:
        workspace_info = workspaceClient.describe_workspaces(WorkspaceIds=[workspace_id])
        workspace_state = workspace_info['Workspaces'][0]['State']

        if workspace_state == 'STOPPED':
            print(f'{workspace_id} is being turned on and will be rebooted...')
            workspaceClient.start_workspaces(StartWorkspaceRequests=[{'WorkspaceId': workspace_id}])
            time.sleep(90)
            workspaceClient.reboot_workspaces(RebootWorkspaceRequests=[{'WorkspaceId': workspace_id}])
            print(f'{workspace_id} was rebooted.')
        elif workspace_state == 'AVAILABLE':
            workspaceClient.reboot_workspaces(RebootWorkspaceRequests=[{'WorkspaceId': workspace_id}])
            print(f'{workspace_id} was rebooted.')
    except Exception as e:
        print(f'An error occurred for workspace {workspace_id}: {str(e)}')

def lambda_handler(event, context):
    try:
        # Retrieve existing workspace IDs by paginating through all pages
        workspaceList = []
        paginator = workspaceClient.get_paginator('describe_workspaces')
        for page in paginator.paginate():
            for workspace in page['Workspaces']:
                workspaceList.append(workspace['WorkspaceId'])

        # Reboot workspaces concurrently
        with concurrent.futures.ThreadPoolExecutor() as executor:
            executor.map(reboot_workspace, workspaceList)

    except Exception as e:
        print(f'An error occurred while retrieving workspace IDs: {str(e)}')
