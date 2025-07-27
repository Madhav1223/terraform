# Set up AWS provider
provider "aws" {
  region = var.region
}

# Random provider for unique naming
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}



# Output the website URL
