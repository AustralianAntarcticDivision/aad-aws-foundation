# Account-level resources shared by every project in the AAD AWS account (334668851926)

# Set up terraform remote state on S3
terraform {
  backend "s3" {
    bucket = "aad-aws-foundation-terraform-state"
    key    = "foundation"
    region = "us-west-2"
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-west-2"
}

# GitHub Actions authenticates to AWS using OIDC, no stored AWS keys.
# Only one provider per URL is allowed per account, so each repo creates its own
# role trusting this provider rather than its own provider.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# Adopt the provider that ghrsst-cogger originally created. Safe to delete once applied
import {
  to = aws_iam_openid_connect_provider.github
  id = "arn:aws:iam::334668851926:oidc-provider/token.actions.githubusercontent.com"
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
