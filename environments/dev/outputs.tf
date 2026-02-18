output "alb_dns_name" {
  value = module.alb_dev.alb_dns_name
}

output "dev_url" {
  value = "http://${module.alb_dev.alb_dns_name}/dev/"
}
