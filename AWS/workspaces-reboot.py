#!/usr/bin/python3

# The following function will reboot all workspaces one at a time.

import boto3
from botocore.config import Config
import time

config = Config(
    retries={
        'max_attempts': 10,
        'mode': 'standard'
    }
)

workspaceClient = boto3.client('workspaces', region_name='us-east-1', config=config)

try:
    # Retrieve existing workspace IDs
    response = workspaceClient.describe_workspaces()
    workspaceList = [workspace['WorkspaceId'] for workspace in response['Workspaces']]
    
    for workspace_id in workspaceList:
        try:
            workspace_info = workspaceClient.describe_workspaces(WorkspaceIds=[workspace_id])
            workspace_state = workspace_info['Workspaces'][0]['State']
            
            if workspace_state == 'STOPPED':
                print(f'{workspace_id} is being turned on and will be rebooted...')
                workspaceClient.start_workspaces(StartWorkspaceRequests=[{'WorkspaceId': workspace_id}])
                time.sleep(180)  # Wait for 180 seconds
                workspaceClient.reboot_workspaces(RebootWorkspaceRequests=[{'WorkspaceId': workspace_id}])
                print(f'{workspace_id} was rebooted.')
            elif workspace_state == 'AVAILABLE':
                workspaceClient.reboot_workspaces(RebootWorkspaceRequests=[{'WorkspaceId': workspace_id}])
                print(f'{workspace_id} was rebooted.')
        except Exception as e:
            print(f'An error occurred for workspace {workspace_id}: {str(e)}')
except Exception as e:
    print(f'An error occurred while retrieving workspace IDs: {str(e)}')
