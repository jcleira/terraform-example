 /*
 * ECR repository created to maintain wordpress docker images.
 */
resource "aws_ecr_repository" "main" {
  name = var.name
}

/*
* ECR policy to keep just the last 20 images.
*
* ECR disk usage might become wild with Wordpress images This policy will keep
* an eye on that.
*
* TODO: If the current running image gets deleted using this policy we might
* have problems on auto-scaling, possible solutions:
*
* - Use an untagged policy?
*/
resource "aws_ecr_lifecycle_policy" "main" {
  repository = "${aws_ecr_repository.main.name}"
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 20 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 20
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
