import boto3
import os
import logging
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Config from environment variables (set these in Lambda config)
BUCKET    = os.environ['S3_BUCKET']
SENDER    = os.environ['SES_SENDER']
RECIPIENTS = os.environ['SES_RECIPIENTS'].split(',')  # "a@x.com,b@x.com"
SUBJECT   = os.environ.get('EMAIL_SUBJECT', 'Reminder: End Your Workspace Session')

IMAGE_KEYS = [
    ('images/wspooles1.png', 'image1', 'wspooles1.png'),
    ('images/wspooles2.png', 'image2', 'wspooles2.png'),
]

s3  = boto3.client('s3',  region_name='us-east-1')
ses = boto3.client('ses', region_name='us-east-1')


def fetch_image(key: str) -> bytes:
    """Fetch an object from S3 and return its bytes."""
    try:
        return s3.get_object(Bucket=BUCKET, Key=key)['Body'].read()
    except ClientError as e:
        logger.error(f"Failed to fetch s3://{BUCKET}/{key}: {e}")
        raise


def build_email(images: list[tuple[bytes, str, str]]) -> MIMEMultipart:
    """
    Build a multipart/related MIME email with an HTML body and inline images.
    images: list of (data, content_id, filename)
    """
    # Outer container
    msg = MIMEMultipart('related')
    msg['Subject'] = SUBJECT
    msg['From']    = SENDER
    msg['To']      = ', '.join(RECIPIENTS)

    # multipart/alternative lets clients choose HTML or plain text
    alternative = MIMEMultipart('alternative')
    msg.attach(alternative)

    plain_text = (
        "Hi Team,\n\n"
        "Please remember to end your Workspace session once you are done for the day.\n"
        "This will allow you to have enough resource capacity to connect in the future.\n\n"
        "Thanks,\nBirdsong Cloud Team"
    )
    alternative.attach(MIMEText(plain_text, 'plain'))

    html_body = """
    <html>
      <body>
        <p>Hi Team,</p>
        <p>Please remember to <strong>end your Workspace session</strong> 
           once you are done for the day.</p>
        <p>This will allow you to have enough resource capacity to connect 
           to your Workspace sessions in the future.</p>
        <br>
        <img src="cid:image1" style="max-width:600px;" /><br><br>
        <img src="cid:image2" style="max-width:600px;" /><br><br>
        <p>Thanks,<br>Birdsong Cloud Team</p>
      </body>
    </html>
    """
    alternative.attach(MIMEText(html_body, 'html'))

    # Attach inline images to the outer 'related' container
    for data, cid, filename in images:
        img_mime = MIMEImage(data, name=filename)
        img_mime.add_header('Content-ID', f'<{cid}>')
        img_mime.add_header('Content-Disposition', 'inline', filename=filename)
        img_mime.add_header('Content-Transfer-Encoding', 'base64')
        msg.attach(img_mime)

    return msg


def lambda_handler(event, context):
    logger.info(f"Event received: {event}")

    # 1. Fetch images from S3
    images = []
    for key, cid, filename in IMAGE_KEYS:
        data = fetch_image(key)
        images.append((data, cid, filename))

    # 2. Build the email
    msg = build_email(images)

    # 3. Send via SES
    try:
        response = ses.send_raw_email(
            Source=SENDER,
            Destinations=RECIPIENTS,
            RawMessage={'Data': msg.as_string()}
        )
        logger.info(f"Email sent. MessageId: {response['MessageId']}")
        return {'statusCode': 200, 'messageId': response['MessageId']}
    except ClientError as e:
        logger.error(f"SES send failed: {e}")
        raise
