/*
* This ECS service will be responsible of running the wordpress application
* given the provided task definition.
*
* TODO Currently we are using a previously configured ELB, but we might use an
* ALB.
*
* Using binpack with CPU will allow us to place the task on instances with the
* least available CPU, that will help us to reduce the number of instances.
*
* TODO does "spread" placement strategy suit better for us?.
*
*/
resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = var.ecs_cluster_id
  task_definition = var.ecs_task_definition_arn
  desired_count   = 2

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    elb_name = var.elb_name
    container_name = var.name
    container_port = 80
  }
}
