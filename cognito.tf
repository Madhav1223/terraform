# Create Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "main-user-pool"

  username_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Account Confirmation"
    email_message        = "Your confirmation code is {####}"
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "given_name"
    required                 = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "family_name"
    required                 = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "custom:role"
    required                 = false

    string_attribute_constraints {
      min_length = 1
      max_length = 50
    }
  }
}

# Create Cognito User Pool Client
resource "aws_cognito_user_pool_client" "main" {
  name         = "main-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  callback_urls = [
    "https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/",
    "http://localhost:3000" # For local development
  ]

  logout_urls = [
    "https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/",
    "http://localhost:3000" # For local development
  ]

  supported_identity_providers = ["COGNITO"]
}

# Create Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "tumauli-auth-${random_string.domain_suffix.result}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Random string for unique domain
resource "random_string" "domain_suffix" {
  length  = 8
  special = false
  upper   = false
}
