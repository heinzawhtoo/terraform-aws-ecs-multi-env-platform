output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "alb_arn" {
  value = module.alb_prod.alb_arn
}

output "alb_dns_name" {
  value = module.alb_prod.alb_dns_name
}

output "alb_zone_id" {
  value = module.alb_prod.alb_zone_id
}

output "alb_security_group_id" {
  value = module.alb_prod.alb_security_group_id
}

output "listener_arn" {
  value = module.alb_prod.listener_arn
}
