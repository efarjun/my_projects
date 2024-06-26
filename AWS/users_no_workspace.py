# The following script iterates through a list of users and returns their username if a workspace does not exist for them.

#!/usr/bin/python3

import boto3

# Initialize the AWS Workspaces client
client = boto3.client('workspaces', region_name='us-east-1')

# List of usernames to check
usernames = ["user1", "user2"]
# Directory ID for your AWS Workspaces directory
directory_id = "d-12345" # Specify ID of directory

# Iterate over the list and get the Workspace ID or an error message
for username in usernames:
    try:
        # Describe the Workspaces for the specified username and directory ID
        response = client.describe_workspaces(
            DirectoryId=directory_id,
            UserName=username
        )

        # Check if there are Workspaces for the user
        if len(response['Workspaces']) > 0:
            workspace_id = response['Workspaces'][0]['WorkspaceId']
        else:
            print(f"{username}")
    except Exception as e:
        print(f"{username}: Error - {str(e)}")
