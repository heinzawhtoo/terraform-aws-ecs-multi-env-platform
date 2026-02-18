output "alb_arn" {
  value = local.alb_arn_actual
}

output "alb_dns_name" {
  value = local.alb_dns_name_actual
}

output "alb_zone_id" {
  value = local.alb_zone_id_actual
}

output "alb_security_group_id" {
  value = local.alb_sg_id_actual
}

output "listener_arn" {
  value = local.listener_arn_actual
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
