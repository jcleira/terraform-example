variable "name" {
  type        = string
  description = "RDS database name"
}

variable "vpc_database_subnets" {
  type        = list(string)
  description = "The previously provisioned VPC database subnets"
}

variable "vpc_default_security_group_id" {
  type        = string
  description = "The previously provisioned VPC default's SG ID"
}
