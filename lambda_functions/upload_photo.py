import json
import boto3
import base64
import uuid
import datetime
import os
from urllib.parse import unquote

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

def handler(event, context):
    print("Event:", json.dumps(event))
    
    try:
        # Get environment variables
        bucket_name = os.environ['PHOTO_BUCKET']
        table_name = os.environ['PHOTO_TABLE']
        table = dynamodb.Table(table_name)
        
        # Parse the request
        body = json.loads(event['body'])
        
        # Get user info from JWT token
        claims = event['requestContext']['authorizer']['claims']
        user_id = claims['sub']
        user_email = claims['email']
        
        # Extract file info
        file_content = body['file_content']  # base64 encoded
        file_name = body['file_name']
        file_type = body['file_type']
        description = body.get('description', '')
        
        # Generate unique photo ID
        photo_id = str(uuid.uuid4())
        
        # Create S3 key
        file_extension = file_name.split('.')[-1] if '.' in file_name else 'jpg'
        s3_key = f"photos/{user_id}/{photo_id}.{file_extension}"
        
        # Decode base64 file content
        file_data = base64.b64decode(file_content.split(',')[1])  # Remove data:image/jpeg;base64, prefix
        
        # Upload to S3
        s3.put_object(
            Bucket=bucket_name,
            Key=s3_key,
            Body=file_data,
            ContentType=file_type,
            Metadata={
                'user_id': user_id,
                'user_email': user_email,
                'original_filename': file_name,
                'description': description
            }
        )
        
        # Store metadata in DynamoDB
        table.put_item(
            Item={
                'photo_id': photo_id,
                'user_id': user_id,
                'user_email': user_email,
                'file_name': file_name,
                'file_type': file_type,
                'file_size': len(file_data),
                's3_key': s3_key,
                'description': description,
                'uploaded_at': datetime.datetime.utcnow().isoformat(),
                'bucket_name': bucket_name
            }
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            'body': json.dumps({
                'success': True,
                'message': 'Photo uploaded successfully',
                'photo_id': photo_id,
                'url': f"https://{bucket_name}.s3.amazonaws.com/{s3_key}"
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            'body': json.dumps({
                'success': False,
                'error': str(e)
            })
        }
