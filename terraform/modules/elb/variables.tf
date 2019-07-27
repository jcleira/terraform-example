variable "name" {
  type        = string
  description = "The ELB name"
}

variable "vpc_allow_http_security_group_id" {
  type        = string
  description = "The previously provisioned VPC Allow HTTP Security Group ID"
}

variable "vpc_public_subnets" {
  type        =  list(string)
  description = "The previously provisioned VPC public subnets"
}
