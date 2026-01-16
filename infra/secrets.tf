data "aws_ssm_parameter" "gitlab_token" {
  name = var.gitlab_token_ssm_parameter_name
}