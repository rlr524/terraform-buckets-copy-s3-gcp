variable "gcp_project" {
  description = "The applicable GCP project id"
  type        = string
  default     = "emiya-file-transfer-service"
}

variable "aws_s3_bucket" {
  description = "The S3 bucket being copied to GCP"
  type        = string
  default     = "emiya-todo-service-files-dev"
}

variable "gcp_storage_bucket" {
  description = "The GCP storage bucket being copied to"
  type        = string
  default     = "emiya-todo-service-files-in"
}