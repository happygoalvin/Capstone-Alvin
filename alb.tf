# Create an Application Load Balancer
# terraform aws create application load balancer (Google)
resource "aws_lb" "alvin_alb" {
  name               = "alvin-webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnet_mapping {
    subnet_id = aws_subnet.alvin_subnet_1a.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.alvin_subnet_1b.id
  }

  enable_deletion_protection = false

  tags = {
    Name = "alvin_alb"
  }
}

# Create Target Group
# terraform aws create target group (Google)
resource "aws_lb_target_group" "alvin_alb_target_group" {
  name        = "alvin-alb-tg"
  target_type = "instance"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.alvin_vpc.id

  health_check {
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "alvin-alb-target-group"
  }
}

# Associate ALB to Target Group
resource "aws_lb_target_group_attachment" "alvin_alb_tg_association" {
  target_group_arn = aws_lb_target_group.alvin_alb_target_group.arn
  target_id        = aws_instance.alvin_al2_wp.id
  port             = 8080
}

# Create a Listener on Port 80
# Terraform aws create listener (Google)
resource "aws_lb_listener" "alvin_alb_listener_HTTP" {
  load_balancer_arn = aws_lb.alvin_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alvin_alb_target_group.arn
  }

  tags = {
    Name = "alvin_alb_listener_HTTP"
  }
}


