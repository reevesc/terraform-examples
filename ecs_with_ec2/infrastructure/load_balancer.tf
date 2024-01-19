#
# Application Load Balancer
#

resource "aws_lb" "app_lb" {
  name               = "${var.app_name}-${var.environment_name}-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.http.id]
}

resource "aws_lb_target_group" "app" {
  name_prefix = "app-"
  vpc_id      = aws_vpc.main.id
  protocol    = var.lb_tg_protocol
  port        = var.lb_tg_port
  target_type = var.lb_tg_target_type

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    matcher             = 200
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.id
  port              = 80
  protocol          = "HTTP"

  # HTTPS Redirect
  default_action {
    type          = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  # HTTP support only
  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.app.id
  # }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app_lb.id
  port = "443"
  protocol  = "HTTPS"
  certificate_arn = aws_acm_certificate.lb_certificate.arn
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  depends_on = [ aws_acm_certificate.lb_certificate ]
}