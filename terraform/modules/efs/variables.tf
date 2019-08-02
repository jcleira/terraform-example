/*
* The name var flow to all components to create a homogeneus naming for the
* provisioned resources
*/
variable "name" {
  type        = string
  description = "The EFS file system name"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "The previously provisioned VPC private subnets"
}

variable "vpc_default_security_group_id" {
  type        = string
  description = "The previously provisioned VPC default's SG ID"
}

