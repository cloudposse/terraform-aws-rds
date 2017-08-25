output "instance_id" {
  value = "${aws_db_instance.default.id}"
}

output "instance_address" {
  value = "${aws_db_instance.default.address}"
}

output "instance_endpoint" {
  value = "${aws_db_instance.default.endpoint}"
}

output "subnet_group_id" {
  value = "${aws_db_subnet_group.default.id}"
}

output "security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "parameter_group_id" {
  value = "${aws_db_parameter_group.default.id}"
}

output "hostname" {
  value = "${module.dns_host_name.hostname}"
}
