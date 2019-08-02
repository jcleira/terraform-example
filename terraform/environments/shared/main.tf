#!/bin/bash

provider "aws" {
  region = "eu-west-1"
}

module "ecr" {
  source = "../../modules/ecr"
  name = var.name
}
