/*
* Configured & configurable options docs & info could be found within the
* module for:
*
* - VPC
* - ECR
* - ECS
*/
provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../modules/vpc"
  name = var.name
}

module "elb" {
  source = "../../modules/elb"
  name = var.name

  vpc_public_subnets               = module.vpc.public_subnets
  vpc_allow_http_security_group_id = module.vpc.allow_http_security_group_id
}

module "rds" {
  source = "../../modules/rds"
  name = var.name

  vpc_database_subnets          = module.vpc.database_subnets
  vpc_default_security_group_id = module.vpc.default_security_group_id
}

module "efs" {
  source = "../../modules/efs"
  name = var.name

  vpc_private_subnets           = module.vpc.private_subnets
  vpc_default_security_group_id = module.vpc.default_security_group_id
}

module "ecs-instance-profile" {
  source = "../../modules/ecs-instance-profile"
  name = var.name
}

module "ecs" {
  source = "../../modules/ecs"
  name = var.name

  vpc_private_subnets           = module.vpc.private_subnets
  vpc_default_security_group_id = module.vpc.default_security_group_id
  ecs_instance_profile_name     = module.ecs-instance-profile.name
}

module "ecs-task-definition" {
  source = "../../modules/ecs-task-definition"
  name = var.name

  wordpress_db_host = module.rds.aws_rds_endpoint
  wordpress_db_name = module.rds.aws_rds_db_name
  wordpress_db_user = module.rds.aws_rds_db_user
  wordpress_db_pass = module.rds.aws_rds_db_pass

  ecr_repository_url = "${var.aws_account}.dkr.ecr.eu-west-1.amazonaws.com/${var.name}"
  docker_image_tag   = "latest"
}

module "ecs-service" {
  source = "../../modules/ecs-service"
  name = var.name

  elb_name                = module.elb.name
  ecs_cluster_id          = module.ecs.id
  ecs_task_definition_arn = module.ecs-task-definition.arn
}

