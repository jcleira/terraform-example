/*
* The name var flow to all components to create a homogeneus naming for the
* provisioned resources
*/
variable "name" {
  type        = string
  description = "The ECS cluster name"
}

variable "vpc_default_security_group_id" {
  type        = string
  description = "The previously provisioned VPC default's SG ID"
}

variable "vpc_private_subnets" {
  type        =  list(string)
  description = "The previously provisioned VPC private subnets"
}

variable "ecs_instance_profile_name" {
  type        = string
  description = "The previously provisioned ECS IAM Role Name"
}
