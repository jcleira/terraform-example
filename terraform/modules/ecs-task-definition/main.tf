/*
* This task definition defines the wordpress application deployment, It does
* set the following settings for the ECS cluster:
*
* - Docker Image & Tag to run on the task.
* - Amount of CPU & memory to allocate.
* - Port mappings.
* - Environment variable configuration.
*
* All that information might be find on the service.json file
*
* It does also configures the EFS volume that contains Wordpress customized
* files.
*/
data "template_file" "wordpress-task-definition" {
  template = file("${path.module}/service.json")

  vars = {
    name = "${var.name}"

    repository = "${var.ecr_repository_url}"
    tag        = "${var.docker_image_tag}"

    wordpress_db_host = "${var.wordpress_db_host}"
    wordpress_db_name = "${var.wordpress_db_name}"
    wordpress_db_user = "${var.wordpress_db_user}"
    wordpress_db_pass = "${var.wordpress_db_pass}"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                = "service"
  container_definitions = data.template_file.wordpress-task-definition.rendered

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }
}
