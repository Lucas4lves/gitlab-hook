# REMOTE BACKEND

variable "bucket_name" {
  type = string
  default = ""
}

# API GATEWAY 
variable "rest_api_name" {
  type    = string
  default = "gitlab-webhook"
}

variable "rest_api_path" {
  type    = string
  default = "summarize"
}

variable "rest_api_key" {
  type = string
  default = ""
}

variable "rest_api_key_usage_plan" {
  type = string
  default = "webhook-producer-usage-plan"
}

# LAMBDA

variable "lambda_function_name" {
  type    = string
  default = "summarize"
}

variable "gitlab_token_ssm_parameter_name" {
  type = string
  default = "/dev/gitlab_webhook_token"
}

# SQS

variable "regular_qeue_name" {
  type    = string
  default = "regular-qeue.fifo"
}

# COMMON

variable "aws_region" {
  type = string
  default = "us-east-1"
}