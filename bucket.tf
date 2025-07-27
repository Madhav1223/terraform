# Create S3 bucket for static website hosting
resource "aws_s3_bucket" "static_website" {
  bucket = "tumauli3232323" # Change this to a unique bucket name
}

# Configure bucket public access block (allow public read)
resource "aws_s3_bucket_public_access_block" "static_website_pab" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Add bucket policy for public read access
resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket     = aws_s3_bucket.static_website.id
  depends_on = [aws_s3_bucket_public_access_block.static_website_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "static_website_versioning" {
  bucket = aws_s3_bucket.static_website.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# Configure S3 static website hosting
resource "aws_s3_bucket_website_configuration" "static_website_config" {
  bucket = aws_s3_bucket.static_website.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Upload the index.html file to the S3 bucket
resource "aws_s3_object" "index_file" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "index.html"
  content = templatefile("${path.module}/html/index.html", {
    cognito_login_url   = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.main.id}&response_type=code&scope=email+openid+profile&redirect_uri=https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/"
    cognito_signup_url  = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.region}.amazoncognito.com/signup?client_id=${aws_cognito_user_pool_client.main.id}&response_type=code&scope=email+openid+profile&redirect_uri=https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/"
    user_pool_id        = aws_cognito_user_pool.main.id
    user_pool_client_id = aws_cognito_user_pool_client.main.id
    cognito_domain      = aws_cognito_user_pool_domain.main.domain
  })
  content_type = "text/html"
}

# Upload the CSS file
resource "aws_s3_object" "style_file" {
  bucket       = aws_s3_bucket.static_website.bucket
  key          = "style.css"
  source       = "html/style.css"
  content_type = "text/css"
}

# Upload the JavaScript file
resource "aws_s3_object" "js_file" {
  bucket       = aws_s3_bucket.static_website.bucket
  key          = "index.js"
  source       = "html/index.js"
  content_type = "application/javascript"
}

# Generate and upload dynamic config file
resource "aws_s3_object" "config_file" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "config.js"
  content = templatefile("${path.module}/html/config.js.template", {
    region              = var.region
    user_pool_id        = aws_cognito_user_pool.main.id
    user_pool_client_id = aws_cognito_user_pool_client.main.id
    auth_domain         = "${aws_cognito_user_pool_domain.main.domain}.auth.${var.region}.amazoncognito.com"
    s3_bucket_name      = aws_s3_bucket.static_website.bucket
    website_url         = "https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com"
    api_gateway_url     = "https://placeholder-api.execute-api.${var.region}.amazonaws.com/prod"
    photo_bucket_name   = "placeholder-photo-bucket"
  })
  content_type = "application/javascript"
}

# Upload the error.html file
resource "aws_s3_object" "error_file" {
  bucket       = aws_s3_bucket.static_website.bucket
  key          = "error.html"
  source       = "html/error.html"
  content_type = "text/html"
}

