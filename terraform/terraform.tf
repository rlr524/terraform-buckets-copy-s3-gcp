terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.7.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "6.46.0"
    }
  }
}