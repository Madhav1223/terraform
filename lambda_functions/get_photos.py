import json
import boto3
import os
from boto3.dynamodb.conditions import Key

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

def handler(event, context):
    print("Event:", json.dumps(event))
    
    try:
        # Get environment variables
        bucket_name = os.environ['PHOTO_BUCKET']
        table_name = os.environ['PHOTO_TABLE']
        table = dynamodb.Table(table_name)
        
        # Get user info from JWT token
        claims = event['requestContext']['authorizer']['claims']
        user_id = claims['sub']
        user_email = claims['email']
        
        # Check if user has admin role (from custom attributes or groups)
        user_role = claims.get('custom:role', 'customer')
        is_admin = user_role.lower() in ['admin', 'manager']
        
        # Query photos based on user role
        if is_admin:
            # Admin can see all photos
            response = table.scan()
        else:
            # Regular users can only see their own photos
            response = table.query(
                IndexName='user-index',
                KeyConditionExpression=Key('user_id').eq(user_id)
            )
        
        photos = []
        for item in response['Items']:
            # Generate presigned URL for each photo
            presigned_url = s3.generate_presigned_url(
                'get_object',
                Params={'Bucket': bucket_name, 'Key': item['s3_key']},
                ExpiresIn=3600  # 1 hour
            )
            
            photos.append({
                'photo_id': item['photo_id'],
                'user_id': item['user_id'],
                'user_email': item['user_email'],
                'file_name': item['file_name'],
                'description': item.get('description', ''),
                'uploaded_at': item['uploaded_at'],
                'file_size': item.get('file_size', 0),
                'url': presigned_url
            })
        
        # Sort photos by upload date (newest first)
        photos.sort(key=lambda x: x['uploaded_at'], reverse=True)
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'success': True,
                'photos': photos,
                'user_role': user_role,
                'is_admin': is_admin,
                'total_count': len(photos)
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'success': False,
                'error': str(e)
            })
        }
