# Use existing lab role for Lambda functions
data "aws_iam_role" "lambda_role" {
  name = "LabRole"
}

# Lambda function for photo upload
resource "aws_lambda_function" "upload_photo" {
  filename      = "upload_photo.zip"
  function_name = "upload-photo"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "upload_photo.handler"
  runtime       = "python3.9"
  timeout       = 30

  environment {
    variables = {
      PHOTO_BUCKET = aws_s3_bucket.photo_storage.bucket
      PHOTO_TABLE  = aws_dynamodb_table.photos.name
    }
  }

  depends_on = [data.archive_file.upload_photo_zip]
}

# Lambda function for getting photos
resource "aws_lambda_function" "get_photos" {
  filename      = "get_photos.zip"
  function_name = "get-photos"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "get_photos.handler"
  runtime       = "python3.9"
  timeout       = 30

  environment {
    variables = {
      PHOTO_BUCKET = aws_s3_bucket.photo_storage.bucket
      PHOTO_TABLE  = aws_dynamodb_table.photos.name
    }
  }

  depends_on = [data.archive_file.get_photos_zip]
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "upload_photo_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_photo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.photo_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_photos_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_photos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.photo_api.execution_arn}/*/*"
}

# S3 bucket for photo storage
resource "aws_s3_bucket" "photo_storage" {
  bucket = "tumauli-photos-${random_string.photo_bucket_suffix.result}"
}

resource "random_string" "photo_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "photo_storage_versioning" {
  bucket = aws_s3_bucket.photo_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "photo_storage_encryption" {
  bucket = aws_s3_bucket.photo_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for photo metadata
resource "aws_dynamodb_table" "photos" {
  name         = "photo-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "photo_id"

  attribute {
    name = "photo_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "uploaded_at"
    type = "S"
  }

  global_secondary_index {
    name            = "user-index"
    hash_key        = "user_id"
    range_key       = "uploaded_at"
    projection_type = "ALL"
  }

  tags = {
    Name = "PhotoMetadata"
  }
}

# Archive data sources for Lambda functions
data "archive_file" "upload_photo_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/upload_photo.py"
  output_path = "${path.module}/upload_photo.zip"
}

data "archive_file" "get_photos_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/get_photos.py"
  output_path = "${path.module}/get_photos.zip"
}
