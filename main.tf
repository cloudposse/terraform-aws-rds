module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  enabled    = "${var.enabled}"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

module "final_snapshot_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  enabled    = "${var.enabled}"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = ["${compact(concat(var.attributes, list("final", "snapshot")))}"]
  tags       = "${var.tags}"
}

locals {
  enabled                   = "${var.enabled == "true"}"
  parameter_group_name      = "${length(var.parameter_group_name) > 0 ? var.parameter_group_name : join("", aws_db_parameter_group.default.*.name)}"
  final_snapshot_identifier = "${length(var.final_snapshot_identifier) > 0 ? var.final_snapshot_identifier : module.final_snapshot_label.id}"
  kms_key_id                = "${length(var.kms_key_id) > 0 ? var.kms_key_id : join("", aws_kms_key.default.*.id)}"
}

resource "aws_kms_key" "default" {
  count                   = "${local.enabled && length(var.kms_key_id) == 0 ? 1 : 0}"
  description             = "${module.label.id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = "${module.label.tags}"
}

resource "aws_db_instance" "default" {
  count                       = "${local.enabled ? 1 : 0}"
  identifier                  = "${module.label.id}"
  name                        = "${var.database_name}"
  username                    = "${var.database_user}"
  password                    = "${var.database_password}"
  port                        = "${var.database_port}"
  engine                      = "${var.engine}"
  engine_version              = "${var.engine_version}"
  instance_class              = "${var.instance_class}"
  allocated_storage           = "${var.allocated_storage}"
  storage_encrypted           = "${var.storage_encrypted}"
  vpc_security_group_ids      = "${aws_security_group.default.*.id}"
  db_subnet_group_name        = "${join("", aws_db_subnet_group.default.*.name)}"
  parameter_group_name        = "${local.parameter_group_name}"
  multi_az                    = "${var.multi_az}"
  storage_type                = "${var.storage_type}"
  iops                        = "${var.iops}"
  publicly_accessible         = "${var.publicly_accessible}"
  snapshot_identifier         = "${var.snapshot_identifier}"
  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"
  apply_immediately           = "${var.apply_immediately}"
  maintenance_window          = "${var.maintenance_window}"
  skip_final_snapshot         = "${var.skip_final_snapshot}"
  copy_tags_to_snapshot       = "${var.copy_tags_to_snapshot}"
  backup_retention_period     = "${var.backup_retention_period}"
  backup_window               = "${var.backup_window}"
  tags                        = "${module.label.tags}"
  final_snapshot_identifier   = "${local.final_snapshot_identifier}"
  kms_key_id                  = "${local.kms_key_id}"
  monitoring_interval         = "${var.monitoring_interval}"
  replicate_source_db         = "${var.replicate_source_db}"
}

resource "aws_db_parameter_group" "default" {
  count     = "${local.enabled && (length(var.parameter_group_name) == 0) ? 1 : 0}"
  name      = "${module.label.id}"
  family    = "${var.db_parameter_group}"
  tags      = "${module.label.tags}"
  parameter = "${var.db_parameter}"
}

resource "aws_db_subnet_group" "default" {
  count      = "${local.enabled ? 1 : 0}"
  name       = "${module.label.id}"
  subnet_ids = ["${var.subnet_ids}"]
  tags       = "${module.label.tags}"
}

resource "aws_security_group" "default" {
  count       = "${local.enabled ? 1 : 0}"
  name        = "${module.label.id}"
  description = "Allow inbound traffic from the security groups"
  vpc_id      = "${var.vpc_id}"

  tags = "${module.label.tags}"
}

locals {
  security_group_id = "${join("", aws_security_group.default.*.id)}"
}

resource "aws_security_group_rule" "allow_ingress" {
  security_group_id = "${local.security_group_id}"
  type              = "ingress"
  from_port         = "${var.database_port}"
  to_port           = "${var.database_port}"
  protocol          = "tcp"
  security_groups   = ["${var.security_group_ids}"]
}

resource "aws_security_group_rule" "allow_egress" {
  security_group_id = "${local.security_group_id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "dns_host_name" {
  source    = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.2.5"
  namespace = "${var.namespace}"
  name      = "${var.host_name}"
  stage     = "${var.stage}"
  zone_id   = "${var.dns_zone_id}"
  records   = "${aws_db_instance.default.*.address}"
  enabled   = "${local.enabled && length(var.dns_zone_id) > 0 ? "true" : "false"}"
}
