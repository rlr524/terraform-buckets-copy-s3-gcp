provider "aws" {
  region = "us-west-2"
}

provider "google" {
  project = "emiya-todo-list"
  region  = "us-west1"
}

resource "aws_s3_bucket" "emiya_todo_service_files_dev" {
  bucket = "emiya-todo-service-files-dev"
}

resource "aws_iam_role" "s3_access_role" {
  name = "emiya-todo-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "emiya-todo-s3-access-policy"
  description = "Allow List, Get, and Put on emiya-todo-service-files-dev bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListBucket"
      ]
      Resource = "arn:aws:s3:::emiya-todo-service-files-dev"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::emiya-todo-service-files-dev/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role" "google_web_identity_role" {
  name = "emiya-todo-google-web-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "accounts.google.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "accounts.google.com:sub" : "115656257329086782558"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_web_identity_role" {
  role       = aws_iam_role.google_web_identity_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "google_storage_bucket" "emiya_todo_service_files_from_s3_dev" {
  name     = "emiya-todo-service-files-from-s3-dev"
  location = "US"
}


