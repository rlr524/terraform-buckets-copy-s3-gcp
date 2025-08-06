provider "aws" {
  region = "us-west-2"
}

provider "google" {
  project = "emiya-todo-list"
  region  = "us-west1"
}

resource "aws_s3_bucket" "emiya_todo_service_files_dev" {
  bucket = var.aws_s3_bucket
}

resource "aws_iam_role" "s3_access_role" {
  name = "emiya-todo-s3-access-role-dev-aug-fifth"
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
  name        = "emiya-todo-s3-access-policy-dev-aug-fifth"
  description = "Allow List, Get, and Put on emiya-todo-service-files-dev bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListBucket"
      ]
      Resource = "arn:aws:s3:::${var.aws_s3_bucket}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.aws_s3_bucket}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role" "google_web_identity_role" {
  name = "emiya-todo-google-web-identity-role-dev-aug-fifth"

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
  name     = "emiya-todo-service-files-from-s3-dev-aug-fifth"
  location = "US"
}

resource "google_iam_workload_identity_pool" "aws_pool" {
  workload_identity_pool_id = "aws-s3-pool"
  display_name              = "AWS S3 Workload Identity Pool"
  description               = "Pool for AWS s3 Integration"
}

resource "google_iam_workload_identity_pool_provider" "aws_s3_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.aws_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "aws-s3-provider"
  display_name                       = "AWS S3 Provider"
  description                        = "Provider for AWS S3"
  aws {
    account_id = data.aws_caller_identity.current.account_id
  }
}

data "aws_caller_identity" "current" {}

resource "google_storage_transfer_job" "s3-bucket-nightly-copy-to-gcp-storage" {
  description = "Nightly copy of files from S3 bucket to GCP storage bucket"
  project     = var.gcp_project

  transfer_spec {
    aws_s3_data_source {
      bucket_name = var.aws_s3_bucket
      role_arn    = aws_iam_role.google_web_identity_role.arn
    }

    gcs_data_sink {
      bucket_name = google_storage_bucket.emiya_todo_service_files_from_s3_dev.name
    }
  }

  schedule {
    schedule_start_date {
      year  = 2025
      month = 8
      day   = 10
    }

    start_time_of_day {
      hours   = 9
      minutes = 0
      seconds = 0
      nanos   = 0
    }
    repeat_interval = "86400s"
  }
}


