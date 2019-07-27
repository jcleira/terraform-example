/*
* RDS definition that will hold Wordpress need database, a compliant MariaDB
* database will be created for that purpose.
*
* TODO there is no database's special params configuration, we are using
* defaults.
* TODO Many RDS options should be configurable:
* - Instance type.
* - Storage size.
* - Maintenance & Backup windows.
* TODO Hashicorp vault deployment to store secrets (database password)
*/
resource "random_string" "password" {
  length            = 20
  special           = true
  min_special       = 5
  override_special  = "!#$%^&*()-_=+[]{}<>:?"
  keepers           = {
    pass_version  = 1
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = var.name

  engine            = "mariadb"
  engine_version    = "10.3.13"
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  major_engine_version = "10.3"

  # TODO Remove this setting, I'm using it on testing to avoid:
  # https://github.com/terraform-providers/terraform-provider-aws/issues/4597
  # But should be disabled on production (also on deployment) provisioning
  skip_final_snapshot = true

  parameter_group_name = "default.mariadb10.3"
  family               = "mariadb10.3"

  name     = var.name
  username = var.name
  password = random_string.password.result
  port     = "3306"

  vpc_security_group_ids = [var.vpc_default_security_group_id]
  subnet_ids             =  var.vpc_database_subnets

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  parameters = [
    {
      name = "character_set_client"
      value = "utf8"
    },
    {
      name = "character_set_server"
      value = "utf8"
    }
  ]
}
