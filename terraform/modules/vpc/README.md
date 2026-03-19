# VPC Module

This module provisions the base networking layer for an environment.

## Resources

- VPC
- Internet Gateway
- Public subnets
- Private subnets
- NAT Gateway
- Public route table
- Private route tables

## Inputs

- `project_name`
- `environment`
- `vpc_cidr`
- `availability_zones`
- `public_subnet_cidrs`
- `private_subnet_cidrs`
- `enable_nat_gateway`
- `common_tags`

## Outputs

- `vpc_id`
- `vpc_cidr_block`
- `public_subnet_ids`
- `private_subnet_ids`
- `internet_gateway_id`
- `nat_gateway_id`
- `public_route_table_id`
- `private_route_table_ids`