output "arn" {
  description = "The main AWS Task Definition ARN"
  value       = aws_ecs_task_definition.main.arn
}
