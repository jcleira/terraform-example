/*
* Configured & configurable options docs & info could be found within the
* module for:
*
* - VPC
* - ECR
*/
provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../modules/vpc"
  name = var.name
}

module "ecr" {
  source = "../../modules/ecr"
  name = var.name
}
