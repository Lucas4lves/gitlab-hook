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