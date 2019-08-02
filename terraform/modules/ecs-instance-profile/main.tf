/*
* This IAM Role is tailored with the basic policies for an ECS instance profile
* to run:
*
* - AmazonEC2ContainerServiceforEC2Role
*   That give basic ECS access permissions for the instance.
*
* - CloudWatchLogsFullAccess
*   That give full access to write (or read) it's own logs for the instance on
*   CloudWatchLogs.
*/
resource "aws_iam_role" "main" {
  name = var.name
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "main" {
  name = var.name
  role = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role = aws_iam_role.main.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role = aws_iam_role.main.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
