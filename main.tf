module "label" {
  source     = "git::https://github.com/betterworks/terraform-null-label.git?ref=tags/0.12.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

module "final_snapshot_label" {
  source     = "git::https://github.com/betterworks/terraform-null-label.git?ref=tags/0.12.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, ["final", "snapshot"]))
  tags       = var.tags
}

resource "aws_db_instance" "default" {
  count             = var.enabled == "true" ? 1 : 0
  identifier        = module.label.id
  name              = var.snapshot_identifier == "" && var.replicate_source_db == "" ? var.database_name : null
  username          = var.snapshot_identifier == "" && var.replicate_source_db == "" ? var.database_user : null
  password          = var.snapshot_identifier == "" && var.replicate_source_db == "" ? var.database_password : null
  port              = var.database_port
  engine            = var.snapshot_identifier == "" && var.replicate_source_db == "" ? var.engine : null
  engine_version    = var.snapshot_identifier == "" && var.replicate_source_db == "" ? var.engine_version : null
  instance_class    = var.instance_class
  allocated_storage = var.snapshot_identifier == "" && var.replicate_source_db == "" ? var.allocated_storage : null
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_arn
  vpc_security_group_ids = compact(
    concat(
      [join("", aws_security_group.default.*.id)],
      var.associate_security_group_ids,
    ),
  )
  db_subnet_group_name            = var.replicate_source_db == "" ? join("", aws_db_subnet_group.default.*.name) : null
  parameter_group_name            = length(var.parameter_group_name) > 0 ? var.parameter_group_name : join("", aws_db_parameter_group.default.*.name)
  option_group_name               = length(var.option_group_name) > 0 ? var.option_group_name : join("", aws_db_option_group.default.*.name)
  license_model                   = var.license_model
  multi_az                        = var.multi_az
  storage_type                    = var.storage_type
  iops                            = var.iops
  publicly_accessible             = var.publicly_accessible
  replicate_source_db             = var.replicate_source_db
  snapshot_identifier             = var.snapshot_identifier
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  apply_immediately               = var.apply_immediately
  maintenance_window              = var.maintenance_window
  skip_final_snapshot             = var.skip_final_snapshot
  copy_tags_to_snapshot           = var.replicate_source_db == "" ? var.copy_tags_to_snapshot : null
  backup_retention_period         = var.replicate_source_db == "" ? var.backup_retention_period : null
  backup_window                   = var.replicate_source_db == "" ? var.backup_window : null
  tags                            = module.label.tags
  deletion_protection             = var.deletion_protection
  final_snapshot_identifier       = var.replicate_source_db == "" ? length(var.final_snapshot_identifier) > 0 ? var.final_snapshot_identifier : module.final_snapshot_label.id : null
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  performance_insights_enabled    = var.performance_insights_enabled
  lifecycle {
    ignore_changes = [parameter_group_name, db_subnet_group_name]
  }
}

resource "aws_db_parameter_group" "default" {
  count  = length(var.parameter_group_name) == 0 && var.enabled == "true" ? 1 : 0
  name   = module.label.id
  family = var.db_parameter_group
  tags   = module.label.tags
  lifecycle {
    ignore_changes = [parameter]
  }
  dynamic "parameter" {
    for_each = var.db_parameter
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}

resource "aws_db_option_group" "default" {
  count                = length(var.option_group_name) == 0 && var.enabled == "true" ? 1 : 0
  name                 = module.label.id
  engine_name          = var.engine
  major_engine_version = var.major_engine_version
  tags                 = module.label.tags
  dynamic "option" {
    for_each = var.db_options
    content {
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [option]
  }
}

resource "aws_db_subnet_group" "default" {
  count      = var.enabled == "true" ? 1 : 0
  name       = module.label.id
  subnet_ids = var.subnet_ids
  tags       = module.label.tags
}

resource "aws_security_group" "default" {
  count       = var.enabled == "true" ? 1 : 0
  name        = module.label.id
  description = "Allow inbound traffic from the security groups"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = var.security_group_ids
    cidr_blocks     = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.label.tags
}

module "dns_host_name" {
  source    = "git::https://github.com/betterworks/terraform-aws-route53-cluster-hostname.git?ref=tags/0.3.0"
  namespace = var.namespace
  name      = var.host_name
  stage     = var.stage
  zone_id   = var.dns_zone_id
  records   = aws_db_instance.default.*.address
  enabled   = length(var.dns_zone_id) > 0 && var.enabled == "true" ? "true" : "false"
}
