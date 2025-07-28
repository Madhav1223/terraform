# API Gateway for Photo Management
resource "aws_api_gateway_rest_api" "photo_api" {
  name        = "photo-management-api"
  description = "API for photo upload and retrieval with authentication"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource for photos
resource "aws_api_gateway_resource" "photos" {
  rest_api_id = aws_api_gateway_rest_api.photo_api.id
  parent_id   = aws_api_gateway_rest_api.photo_api.root_resource_id
  path_part   = "photos"
}

# CORS for photos resource
resource "aws_api_gateway_method" "photos_options" {
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  resource_id   = aws_api_gateway_resource.photos.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "photos_options" {
  rest_api_id = aws_api_gateway_rest_api.photo_api.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.photos_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "photos_options" {
  rest_api_id = aws_api_gateway_rest_api.photo_api.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.photos_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "photos_options" {
  rest_api_id = aws_api_gateway_rest_api.photo_api.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.photos_options.http_method
  status_code = aws_api_gateway_method_response.photos_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# GET method for retrieving photos
resource "aws_api_gateway_method" "get_photos" {
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  resource_id   = aws_api_gateway_resource.photos.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_photos" {
  rest_api_id             = aws_api_gateway_rest_api.photo_api.id
  resource_id             = aws_api_gateway_resource.photos.id
  http_method             = aws_api_gateway_method.get_photos.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_photos.invoke_arn
}

resource "aws_api_gateway_method_response" "get_photos" {
  rest_api_id = aws_api_gateway_rest_api.photo_api.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.get_photos.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_photos" {
  rest_api_id = aws_api_gateway_rest_api.photo_api.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.get_photos.http_method
  status_code = aws_api_gateway_method_response.get_photos.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.get_photos]
}

# POST method for uploading photos
resource "aws_api_gateway_method" "post_photos" {
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  resource_id   = aws_api_gateway_resource.photos.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "post_photos" {
  rest_api_id             = aws_api_gateway_rest_api.photo_api.id
  resource_id             = aws_api_gateway_resource.photos.id
  http_method             = aws_api_gateway_method.post_photos.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.upload_photo.invoke_arn
}

resource "aws_api_gateway_method_response" "post_photos" {
  rest_api_id = aws_api_gateway_rest_api.photo_api.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.post_photos.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "post_photos" {
  rest_api_id = aws_api_gateway_rest_api.photo_api.id
  resource_id = aws_api_gateway_resource.photos.id
  http_method = aws_api_gateway_method.post_photos.http_method
  status_code = aws_api_gateway_method_response.post_photos.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.post_photos]
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.main.arn]
}

# Gateway Response for CORS on 401 Unauthorized
resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  response_type = "UNAUTHORIZED"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  response_templates = {
    "application/json" = "{\"message\": \"$context.error.messageString\", \"success\": false}"
  }
}

# Gateway Response for CORS on 403 Forbidden
resource "aws_api_gateway_gateway_response" "access_denied" {
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  response_type = "ACCESS_DENIED"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }

  response_templates = {
    "application/json" = "{\"message\": \"$context.error.messageString\", \"success\": false}"
  }
}

# Gateway Response for CORS on 4XX errors
resource "aws_api_gateway_gateway_response" "default_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }
}

# Gateway Response for CORS on 5XX errors
resource "aws_api_gateway_gateway_response" "default_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  response_type = "DEFAULT_5XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "photo_api" {
  depends_on = [
    aws_api_gateway_integration.get_photos,
    aws_api_gateway_integration.post_photos,
    aws_api_gateway_integration.photos_options,
  ]

  rest_api_id = aws_api_gateway_rest_api.photo_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.photos.id,
      aws_api_gateway_method.get_photos.id,
      aws_api_gateway_method.post_photos.id,
      aws_api_gateway_method.photos_options.id,
      aws_api_gateway_integration.get_photos.id,
      aws_api_gateway_integration.post_photos.id,
      aws_api_gateway_integration.photos_options.id,
      aws_api_gateway_gateway_response.unauthorized.id,
      aws_api_gateway_gateway_response.access_denied.id,
      aws_api_gateway_gateway_response.default_4xx.id,
      aws_api_gateway_gateway_response.default_5xx.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "photo_api" {
  deployment_id = aws_api_gateway_deployment.photo_api.id
  rest_api_id   = aws_api_gateway_rest_api.photo_api.id
  stage_name    = "prod"


}
