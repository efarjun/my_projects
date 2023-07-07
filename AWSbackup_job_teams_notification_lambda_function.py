import boto3
import requests

def lambda_handler(event, context):
    # Create a CloudWatch client
    cloudwatch = boto3.client('cloudwatch')

    # Retrieve the relevant information from the event
    backup_job_name = event['detail']['backupJobId']
    backup_job_status = event['detail']['state']
    resource_name = event['detail']['resourceArn']

    # Define the metric namespace and metric name
    namespace = 'Custom/AWSBackup'
    metric_name = 'BackupJobStatus'

    # Define the dimensions for the metric
    dimensions = [
        {
            'Name': 'BackupJobName',
            'Value': backup_job_name
        },
        {
            'Name': 'ResourceName',
            'Value': resource_name
        }
    ]

    # Define the metric value based on the job status
    metric_value = 1 if backup_job_status == 'COMPLETED' else 0

    # Put the metric data
    response = cloudwatch.put_metric_data(
        Namespace=namespace,
        MetricData=[
            {
                'MetricName': metric_name,
                'Dimensions': dimensions,
                'Value': metric_value
            }
        ]
    )

    print(response)

    teams_webhook_url = "<teams webhook url>"

    # Prepare the message to be sent
    message = {
        "text": f"AWS Backup Job Status: {backup_job_status} for {resource_name} (Job ID: {backup_job_name})"
    }

    # Send the message to Teams
    response = requests.post(teams_webhook_url, json=message)

    # Check the response status
    if response.status_code != 200:
        print("Failed to send Teams notification. Status code:", response.status_code)

