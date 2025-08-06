variable "gcp_project" {
  description = "The applicable GCP project id"
  type        = string
  default     = "emiya-todo-list"
}

variable "aws_s3_bucket" {
  description = "The S3 bucket being copied to GCP"
  type        = string
  default     = "emiya-todo-service-files-dev-aug-fifth"
}