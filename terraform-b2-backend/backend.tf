
terraform {
  backend "s3" {
    bucket = "tintinho"
    key    = "terraform/my-deployment.tfstate"
    region = "us-east-1"
    endpoint = "s3.us-west-000.backblazeb2.com"
    access_key = "blah blah blah"
    secret_key = "blah blah blah"
    skip_credentials_validation = true
  }
}
