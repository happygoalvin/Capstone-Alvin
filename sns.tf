# Create an SNS Topic
# Terraform aws create sns topic(Google)
resource "aws_sns_topic" "user_updates" {
  name = "alvin-capstone-topic"
}

# Create an SNS Topic Subscription
# Terraform aws sns topic subscription(Google)
resource "aws_sns_topic_subscription" "notification_topic" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = var.sns_email
}
