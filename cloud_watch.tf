resource "aws_cloudwatch_event_rule" "cloudwatch_event" {
  name                = "cloudwatch-event"
  description         = "Run CodeBuild project at 20:00 every day"
  schedule_expression = "cron(0 20 * * ? *)"
}
