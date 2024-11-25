import boto3
import os
from botocore.exceptions import ClientError

ssm = boto3.client('ssm')
s3 = boto3.client('s3')


def lambda_handler(event, context):
  # Extract the parameter name from the event
  parameter_name = event['detail']['requestParameters']['name']

  try:
    # Get the parameter details
    specific_tags = [
      {'Key': 'CreatedBy', 'Value': 'Terraform'},
      {'Key': 'Backup', 'Value': 'True'}
    ]
    parameter = ssm.get_parameter(Name=parameter_name, WithDecryption=True)
    parameter_value = parameter['Parameter']['Value']
    parameter_tags = ssm.list_tags_for_resource(
      ResourceType='Parameter',
      ResourceId=parameter_name
    )['TagList']
    if all(specific_tag in parameter_tags for specific_tag in specific_tags):
      s3.put_object(
        Bucket=os.environ['S3_BUCKET_NAME'],
        Key=f"ssm-parameters/{parameter_name}",
        Body=parameter_value,
        ContentType='string'
      )
      print(f"Parameter {parameter_name} saved to S3")
    else:
      print(f"Parameter {parameter_name} does not match specific tags")
  except ClientError as e:
    print(f"Error fetching parameter {parameter_name}: {str(e)}")