# aad-aws-foundation

Account-level AWS infrastructure shared by AAD projects (e.g. ghrsst-cogger).

## What's here

- **GitHub Actions OIDC provider**: lets GitHub Actions workflows assume AWS roles without stored keys.
  AWS allows only one provider per URL per account, so it lives here rather than in any one project.

## Using the OIDC provider from another repo

Look it up instead of creating it, then create a role scoped to your repo:

```hcl
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions" {
  name = "my-project-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:AustralianAntarcticDivision/my-project:ref:refs/tags/v*" }
      }
    }]
  })
}
```

## Deploying

State lives in the `aad-aws-foundation-terraform-state` S3 bucket. Terraform can't create its own
state bucket, so it was made once by hand:

```bash
aws s3api create-bucket --bucket aad-aws-foundation-terraform-state --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2
aws s3api put-bucket-versioning --bucket aad-aws-foundation-terraform-state \
  --versioning-configuration Status=Enabled
```

Then:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```
