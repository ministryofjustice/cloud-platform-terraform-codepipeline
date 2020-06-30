// Configure remote state location here...
/*
terraform {
  required_version = ">= 0.11.0"
  backend "s3" {
    bucket = "codedeploy-eks"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
*/

provider "aws" {
  version = "~> 2.7"
  region  = "eu-west-2"
}

