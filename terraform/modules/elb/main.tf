/*
* ELB definition to provide access from "the internet" for the running ECS
* wordpress tasks.
*
* TODO Should this be an ALB instead of an ELB.
*
*/
module "elb" {
  source = "terraform-aws-modules/elb/aws"

  name = var.name

  subnets         = var.vpc_public_subnets
  security_groups = [var.vpc_allow_http_security_group_id]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
      target              = "HTTP:80/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
  }

  tags = {
    Name = var.name
  }
}
