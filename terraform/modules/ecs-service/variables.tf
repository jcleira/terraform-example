variable "name" {
  type        = string
  description = "ECS service name"
}

variable "ecs_cluster_id" {
  type        = string
  description = "The previously provisioned main ECS cluster ID"
}

variable "ecs_task_definition_arn" {
  type        = string
  description = "The previously provisioned ECS Task Definition ARN"
}

variable "elb_name" {
  type        = string
  description = "The previously provisioned main ELB Name"
}
