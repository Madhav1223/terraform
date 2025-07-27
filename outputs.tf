# Output the website URL
output "website_url" {
  description = "URL of the static website"
  value       = "https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com"
}

# Output Cognito URLs
output "cognito_login_url" {
  description = "Cognito hosted UI login URL"
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.main.id}&response_type=code&scope=email+openid+profile&redirect_uri=https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/"
}

output "cognito_signup_url" {
  description = "Cognito hosted UI signup URL"
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.region}.amazoncognito.com/signup?client_id=${aws_cognito_user_pool_client.main.id}&response_type=code&scope=email+openid+profile&redirect_uri=https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/"
}

output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "login_page_url" {
  description = "URL of the login page"
  value       = "https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/login.html"
}

output "register_page_url" {
  description = "URL of the register page"
  value       = "https://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/register.html"
}
