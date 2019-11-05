module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.5"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

module "final_snapshot_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.5"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = ["${compact(concat(var.attributes, list("final", "snapshot")))}"]
  tags       = "${var.tags}"
}

locals {
  versions                      = "${split(".", var.engine_version)}"
  major_version                 = "${element(local.versions,0)}"
  minor_version                 = "${length(local.versions) > 1 ? format(".%s", element(local.versions,1)) : ""}"
  computed_major_engine_version = "${local.major_version}${(var.engine != "postgres" || local.major_version < 10) ? local.minor_version : ""}"
  major_engine_version          = "${var.major_engine_version == "" ? local.computed_major_engine_version : var.major_engine_version}"
}

resource "aws_db_instance" "default" {
  count                       = "${var.enabled == "true" ? 1 : 0}"
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
  kms_key_id                  = "${var.kms_key_arn}"
  vpc_security_group_ids      = ["${compact(concat(list(join("", aws_security_group.default.*.id)), var.associate_security_group_ids))}"]
  db_subnet_group_name        = "${join("", aws_db_subnet_group.default.*.name)}"
  parameter_group_name        = "${length(var.parameter_group_name) > 0 ? var.parameter_group_name : join("", aws_db_parameter_group.default.*.name)}"
  option_group_name           = "${length(var.option_group_name) > 0 ? var.option_group_name : join("", aws_db_option_group.default.*.name)}"
  license_model               = "${var.license_model}"
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
  deletion_protection         = "${var.deletion_protection}"
  final_snapshot_identifier   = "${length(var.final_snapshot_identifier) > 0 ? var.final_snapshot_identifier : module.final_snapshot_label.id}"
}

resource "random_string" "default" {
  length  = 20
  special = false
  upper   = false

  keepers {
    engine_version = "${var.engine_version}"
  }
}

resource "aws_db_parameter_group" "default" {
  count     = "${(length(var.parameter_group_name) == 0 && var.enabled == "true") ? 1 : 0}"
  name      = "${module.label.id}${var.delimiter}${join("", random_string.default.*.result)}"
  family    = "${var.db_parameter_group}"
  tags      = "${module.label.tags}"
  parameter = "${var.db_parameter}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_option_group" "default" {
  count                = "${(length(var.option_group_name) == 0 && var.enabled == "true") ? 1 : 0}"
  name                 = "${module.label.id}${var.delimiter}${random_string.default.result}"
  engine_name          = "${var.engine}"
  major_engine_version = "${local.major_engine_version}"
  tags                 = "${module.label.tags}"
  option               = "${var.db_options}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "default" {
  count      = "${var.enabled == "true" ? 1 : 0}"
  name       = "${module.label.id}"
  subnet_ids = ["${var.subnet_ids}"]
  tags       = "${module.label.tags}"
}

resource "aws_security_group" "default" {
  count       = "${var.enabled == "true" ? 1 : 0}"
  name        = "${module.label.id}"
  description = "RDS Security Group"
  vpc_id      = "${var.vpc_id}"
  tags        = "${module.label.tags}"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = "${var.enabled == "true" ? length(var.security_group_ids) : 0}"
  description              = "Allow inbound traffic from existing Security Groups"
  type                     = "ingress"
  from_port                = "${var.database_port}"
  to_port                  = "${var.database_port}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.security_group_ids, count.index)}"
  security_group_id        = "${join("", aws_security_group.default.*.id)}"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = "${var.enabled == "true" && length(var.allowed_cidr_blocks) > 0 ? 1 : 0}"
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = "${var.database_port}"
  to_port           = "${var.database_port}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.allowed_cidr_blocks}"]
  security_group_id = "${join("", aws_security_group.default.*.id)}"
}

resource "aws_security_group_rule" "egress" {
  count             = "${var.enabled == "true" ? 1 : 0}"
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${join("", aws_security_group.default.*.id)}"
}

module "dns_host_name" {
  source    = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.2.5"
  namespace = "${var.namespace}"
  name      = "${var.host_name}"
  stage     = "${var.stage}"
  zone_id   = "${var.dns_zone_id}"
  records   = "${aws_db_instance.default.*.address}"
  enabled   = "${(length(var.dns_zone_id) > 0 && var.enabled == "true") ? "true" : "false"}"
}
