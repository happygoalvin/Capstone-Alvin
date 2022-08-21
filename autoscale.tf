# Create a launch template using Amazon Linux 2 AMI
resource "aws_launch_template" "as_template" {
  name                   = "alvin-as-template"
  image_id               = var.ec2_ami
  instance_type          = "t2.micro"
  key_name               = var.my-keypair
  vpc_security_group_ids = [aws_security_group.alvin_webapp_sg.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted             = true
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                       = "Alvin Amazon Linux 2 | Wordpress Server"
      Terraform                  = "Yes"
      Environment                = "Dev"
      "Inspector Resource Group" = "Alvin"
    }
  }

  lifecycle {
    ignore_changes = [key_name]
  }
}

# Create an autoscaling group for my Webapp Server instance
resource "aws_autoscaling_group" "alvin-asg" {
  name              = "alvin-asg"
  min_size          = 1
  max_size          = 2
  health_check_type = "EC2"
  # Associate autoscaling group to ALB Target group
  target_group_arns = [aws_lb_target_group.alvin_alb_target_group.arn]
  # Set the Private Subnet IDs in different AZ for instances created in the ASG
  vpc_zone_identifier = [aws_subnet.alvin_subnet_2a.id, aws_subnet.alvin_subnet_2b.id]

  depends_on = [
    aws_launch_template.as_template
  ]

  launch_template {
    id      = aws_launch_template.as_template.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity,
      max_size,
      min_size
    ]
  }
}

# Create Dynamic Autoscaling Policy by target tracking CPU Utilization
# Create instances when CPU Utilization reaches 60%
resource "aws_autoscaling_policy" "as-policy-cpu" {
  autoscaling_group_name    = aws_autoscaling_group.alvin-asg.name
  name                      = "CPU-Utilization-Tracking | Alvin Webapp"
  adjustment_type           = "PercentChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 300
  enabled                   = true

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60
  }
}

# Set an Alarm for CPU Utilization when 
resource "aws_cloudwatch_metric_alarm" "bat" {
  alarm_name          = "webapp-alarm-cpu-over-60"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.alvin-asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization over 60%"
  alarm_actions     = [aws_autoscaling_policy.as-policy-cpu.arn]
}



