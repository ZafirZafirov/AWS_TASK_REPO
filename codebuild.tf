resource "aws_codebuild_project" "aws_project" {
  name          = "aws-project"
  service_role  = aws_iam_role.codebuild.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name  = "COMMAND"
      value = "aws-nuke -c config.yaml --force --no-dry-run"
    }
  }
  source {
    type            = "NO_SOURCE"
    buildspec       = file("${path.module}/buildspec.yml")
  }
}
resource "aws_iam_role" "codebuild" {
  name               = "codebuild"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role" "admin" {
  name               = "admin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_cloudwatch_event_rule" "cloudwatch_event" {
  name                = "cloudwatch-event"
  description         = "Run CodeBuild project at 20:00 every day"
  schedule_expression = "cron(0 20 * * ? *)"
}
resource "aws_cloudwatch_event_target" "role_cloudwatch" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_event.name
  target_id = aws_codebuild_project.aws_project.name
  arn       = aws_codebuild_project.aws_project.arn
}