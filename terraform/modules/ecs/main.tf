/*
* ECS cluster definition
*
* The AMI selected for the cluster would be the AWS ECS optimized AMI.
*
* More info about this AMI on:
* https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
*/
resource "aws_ecs_cluster" "main" {
  name = var.name
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

/*
* ECS cluster autoscalling group, many options for the auto-scaling group should
* be configurable.
*
* TODO VPC default security group shouldn't be used for the deployment a better
* tailored Security Group should be created, for the instances.
* TODO Instance type, min, max & desired capacity should be configurable.
*/
module "ecs" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = var.name
  lc_name = var.name

  image_id             = data.aws_ami.amazon_linux_ecs.id
  instance_type        = "t2.micro"
  security_groups      = [var.vpc_default_security_group_id]
  iam_instance_profile = var.ecs_instance_profile_name

  user_data = "#!/bin/bash\necho ECS_CLUSTER='${var.name}' >> /etc/ecs/ecs.config"

  asg_name                  = var.name
  vpc_zone_identifier       = var.vpc_private_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
}
