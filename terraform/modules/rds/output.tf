output "aws_rds_endpoint" {
  description = "RDS connection endpoint"
  value       = module.rds.this_db_instance_endpoint
}

output "aws_rds_db_name" {
  description = "RDS database name"
  value       = module.rds.this_db_instance_name
}

output "aws_rds_db_user" {
  description = "RDS database user"
  value       = module.rds.this_db_instance_username
}

output "aws_rds_db_pass" {
  description = "RDS database pass"
  value       = module.rds.this_db_instance_password
}
