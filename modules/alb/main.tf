locals {
  alb_arn_actual      = var.create_alb ? aws_lb.this[0].arn : var.existing_alb_arn
  alb_dns_name_actual = var.create_alb ? aws_lb.this[0].dns_name : var.existing_alb_dns_name
  alb_zone_id_actual  = var.create_alb ? aws_lb.this[0].zone_id : var.existing_alb_zone_id
  alb_sg_id_actual    = var.create_alb ? aws_security_group.alb[0].id : var.existing_alb_security_group_id
  listener_arn_actual = var.create_listener ? aws_lb_listener.http[0].arn : var.existing_listener_arn
}

resource "aws_security_group" "alb" {
  count = var.create_alb ? 1 : 0

  name        = "${var.name_prefix}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-alb-sg" })
}

resource "aws_lb" "this" {
  count = var.create_alb ? 1 : 0

  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-alb" })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name_prefix}-${var.target_group_name}"
  port        = var.target_group_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
    path                = var.health_check_path
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.target_group_name}" })
}

resource "aws_lb_listener" "http" {
  count = var.create_listener ? 1 : 0

  load_balancer_arn = local.alb_arn_actual
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener_rule" "path" {
  count = var.create_path_rule ? 1 : 0

  listener_arn = local.listener_arn_actual
  priority     = var.path_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }
}
