output "instance_id" {
  value       = join("", aws_db_instance.default.*.id)
  description = "ID of the instance"
}

output "instance_arn" {
  value       = join("", aws_db_instance.default.*.arn)
  description = "ARN of the instance"
}

output "instance_address" {
  value       = join("", aws_db_instance.default.*.address)
  description = "Address of the instance"
}

output "instance_endpoint" {
  value       = join("", aws_db_instance.default.*.endpoint)
  description = "DNS Endpoint of the instance"
}

output "subnet_group_id" {
  value       = join("", aws_db_subnet_group.default.*.id)
  description = "ID of the created Subnet Group"
}

output "security_group_id" {
  value       = join("", aws_security_group.default.*.id)
  description = "ID of the Security Group"
}

output "parameter_group_id" {
  value       = join("", aws_db_parameter_group.default.*.id)
  description = "ID of the Parameter Group"
}

output "option_group_id" {
  value       = join("", aws_db_option_group.default.*.id)
  description = "ID of the Option Group"
}

output "hostname" {
  value       = module.dns_host_name.hostname
  description = "DNS host name of the instance"
}

output "resource_id" {
  value       = join("", aws_db_instance.default.*.resource_id)
  description = "The RDS Resource ID of this instance."
}

output "instance_user" {
  value       = local.database_user
  description = "RDS Username for the master DB user"
}

output "instance_password_ssm_key" {
  value       = local.ssm_enabled ? local.ssm_key_password : null
  description = "SSM key of RDS password for the master DB user"
}
