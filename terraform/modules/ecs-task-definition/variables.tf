variable "name" {
  type        = string
  description = "RDS database name"
}

variable "wordpress_db_host" {
  type        = string
  description = "Previously deployed RDS host"
}

variable "wordpress_db_name" {
  type        = string
  description = "Previously deployed RDS database name"
}

variable "wordpress_db_user" {
  type        = string
  description = "Previously deployed RDS database user name"
}

variable "wordpress_db_pass" {
  type        = string
  description = "Previously deployed RDS database password"
}

variable "ecr_repository_url" {
  type        = string
  description = "Previously deployed ECR repository URL"
}

variable "docker_image_tag" {
  type        = string
  description = "Docker container image tag to run"
}
