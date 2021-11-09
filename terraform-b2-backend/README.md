
# Using a S3 compatible storage as a Terraform state backend (Backblaze B2)

Create a file named `backend.tf` for storing a the backend configuration

```terraform
terraform {
  backend "s3" {
    # the bucket name in B2
    bucket = "tintinho"

    # the path inside the bucket
    key = "terraform/my-deployment.tfstate"

    # hardcoded value so it will passed the validation
    region = "us-east-1"

    # you can lookup your bucket's "endpoint" on the B2 console
    endpoint = "s3.us-west-000.backblazeb2.com" 

    # place your Backblaze application key id here
    access_key = "<secret here>" 

    # place your Backblaze application key here
    secret_key = "<secret here>" 

    # we need to set this because we are not using AWS
    skip_credentials_validation = true
  }
}
```