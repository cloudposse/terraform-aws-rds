output "replica_instance_id" {
  value       = aws_db_instance.default.*.id
  description = "ID of the instance"
}

output "replica_instance_address" {
  value       = aws_db_instance.default.*.address
  description = "Address of the instance"
}

output "replica_instance_endpoint" {
  value       = aws_db_instance.default.*.endpoint
  description = "DNS Endpoint of the instance"
}