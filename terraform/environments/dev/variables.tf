/*
* The name var flow to all components to create a homogeneus naming for the
* provisioned resources
*/
variable "name" {
  type = "string"
  description = "The base name for all the resources to create"
}

/*
* The AWS account to provision resources to
*/
variable "aws_account" {
  type = "string"
  description = "The AWS account for all the resources to create"
}
