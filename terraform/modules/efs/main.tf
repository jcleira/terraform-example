/*
* This EFS is used to maintain customized Wordpress files uploads, plugins and
* themes.
*
* Mounting EFS as R+W for every running instance might sound scary but actually
* performs very well.
*
* TODO Using S3 / Cloudfront for assets & uploads would be a better solution.
* TODO We might also mount EFS volumes on an instance responsible for the backups.
* TODO Does EFS generalPurpose performance mode meet all use cases requirements?
* TODO VPC's default Security Group is used to match ECS cluster's instances but
* it should have its own, properly grained.
*/
resource "aws_efs_file_system" "main" {
  performance_mode = "generalPurpose"

  tags = {
    Name = var.name
  }
}

resource "aws_efs_mount_target" "main" {
  file_system_id = "${aws_efs_file_system.main.id}"

  count     = "${length(var.vpc_private_subnets)}"
  subnet_id = "${element(var.vpc_private_subnets, count.index)}"

  security_groups = ["${var.vpc_default_security_group_id}"]
}
