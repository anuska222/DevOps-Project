variable "project_name" {
  description = "Project prefix for resource names"
  type        = string
  default     = "devsecops-pipeline"
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}
