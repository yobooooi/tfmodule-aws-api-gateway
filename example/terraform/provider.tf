terraform {
  backend "s3" {
    region  = "eu-west-1"
    bucket  = "globee-terraform-state-dev"
    key     = "eu-west-1/api-gateway/initial-dev/terraform.tfstate"
    profile = "globee"
  }
}

provider "aws" {
  profile = "globee"
  region  = "eu-west-1"
}
