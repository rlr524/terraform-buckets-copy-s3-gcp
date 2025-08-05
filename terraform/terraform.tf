terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.46.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "6.7.0"
    }
  }
}