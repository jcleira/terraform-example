/*
* VPC creation with the following caracteristics.
*
* Region: eu-west-1
* Availability zones: a, b, c
*
* TODO: We should make AWS region and AZs configurable.
*
* Subnets:
* private_subnets: For the wordpress instances, we don't want EC2 instances
* accesible from the internet.
* database_subnets: For the RDS instance, also non accesible from the internet.
* public_subnets: For the ELB/ALB.
*
* One NAT Gateway wil be created per subnet, this configuration has become a
* standard. While probably one NAT Gateway per AZ is enough as you get
* redundancy within the zone, this setting doesn't add extra overhead.
*
* Using no internet access subnets for `Wordpress` has been discarded as that
* configuration might prevent tipical Wordpress actions like:
*
* - Plugin updating.
+ - Email sending.
*
*/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = "10.0.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = {
    Name = var.name
  }
}
