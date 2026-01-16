# API GATEWAY 
variable "rest_api_name" {
  type    = string
  default = "summarize_mr_changes"
}

variable "rest_api_path" {
  type    = string
  default = "summarize"
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