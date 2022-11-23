# This script gves us the date and time an EC2 instances was last stopped.

#!/usr/bin/python3

import boto3
import botocore
import os

awsRegion = os.environ['AWS_DEFAULT_REGION']
stsClient = boto3.client('sts')
account = stsClient.get_caller_identity()['Account']

ec2Client = boto3.client('ec2', region_name=awsRegion)

instances = ec2Client.describe_instances()

for reservation in instances['Reservations']:
    instances = reservation['Instances']
    for instance in instances:
        if instance['State']['Name'] == 'stopped':
            print(f"{instance['InstanceId']}: {instance['StateTransitionReason']}")
