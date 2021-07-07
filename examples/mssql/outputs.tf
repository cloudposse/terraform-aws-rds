output "instance_id" {
  value       = module.rds_instance.instance_id
  description = "ID of the instance"
}

output "instance_address" {
  value       = module.rds_instance.instance_address
  description = "Address of the instance"
}

output "instance_endpoint" {
  value       = module.rds_instance.instance_endpoint
  description = "DNS Endpoint of the instance"
}

output "subnet_group_id" {
  value       = module.rds_instance.subnet_group_id
  description = "ID of the Subnet Group"
}

output "security_group_id" {
  value       = module.rds_instance.security_group_id
  description = "ID of the Security Group"
}

output "parameter_group_id" {
  value       = module.rds_instance.parameter_group_id
  description = "ID of the Parameter Group"
}

output "option_group_id" {
  value       = module.rds_instance.option_group_id
  description = "ID of the Option Group"
}

output "hostname" {
  value       = module.rds_instance.hostname
  description = "DNS host name of the instance"
}

output "public_subnet_cidrs" {
  value = module.subnets.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = module.subnets.private_subnet_cidrs
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}
