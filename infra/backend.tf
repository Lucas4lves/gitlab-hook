terraform {
  backend "s3" {
    key    = "gitlab-webhook.tfstate"
    region = "us-east-1"
    bucket = "devops-tf-states-bucket"
  }
}