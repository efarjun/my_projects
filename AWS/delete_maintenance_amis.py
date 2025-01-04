import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    amis = ec2.describe_images(Filters=[{'Name': 'name', 'Values': ['Maintenance*']}])['Images']
    seven_days_ago = datetime.now() - timedelta(days=7)

    for ami in amis:
        creation_date = ami['CreationDate']
        ami_id = ami['ImageId']

        # Convert creation date string to datetime object
        creation_datetime = datetime.strptime(creation_date, '%Y-%m-%dT%H:%M:%S.%fZ')

        if creation_datetime < seven_days_ago:
            # Deregister the AMI
            ec2.deregister_image(ImageId=ami_id)
            print(f"AMI {ami_id} deregistered.")

            # Delete associated snapshots
            for block_device_mapping in ami['BlockDeviceMappings']:
                if 'Ebs' in block_device_mapping:
                    snapshot_id = block_device_mapping['Ebs']['SnapshotId']
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                    print(f"Snapshot {snapshot_id} deleted.")
