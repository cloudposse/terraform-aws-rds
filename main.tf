module "final_snapshot_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["final", "snapshot"]
  context    = module.this.context
}

locals {
  computed_major_engine_version = var.engine == "postgres" ? join(".", slice(split(".", var.engine_version), 0, 1)) : join(".", slice(split(".", var.engine_version), 0, 2))
  major_engine_version          = var.major_engine_version == "" ? local.computed_major_engine_version : var.major_engine_version

  subnet_ids_provided           = var.subnet_ids != null && length(var.subnet_ids) > 0
  db_subnet_group_name_provided = var.db_subnet_group_name != null && var.db_subnet_group_name != ""
  is_replica                    = try(length(var.replicate_source_db), 0) > 0

  # Db Subnet group name should equal the name if provided
  # we then check if this is a replica, if it is, and no name is provided, this should be null, see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#db_subnet_group_name
  # finally, if no name is provided, and it is not a replica, we check if subnets were provided.
  db_subnet_group_name = local.db_subnet_group_name_provided ? var.db_subnet_group_name : (
    local.is_replica ? null : (
    local.subnet_ids_provided ? join("", aws_db_subnet_group.default[*].name) : null)
  )

  availability_zone = var.multi_az ? null : var.availability_zone
}

resource "aws_db_instance" "default" {
  count = module.this.enabled ? 1 : 0

  identifier            = module.this.id
  db_name               = var.database_name
  username              = local.is_replica ? null : var.database_user
  password              = local.is_replica ? null : var.database_password
  port                  = var.database_port
  engine                = local.is_replica ? null : var.engine
  engine_version        = local.is_replica ? null : var.engine_version
  character_set_name    = var.charset_name
  instance_class        = var.instance_class
  allocated_storage     = local.is_replica ? null : var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_arn

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#manage_master_user_password
  manage_master_user_password   = local.is_replica || var.database_password != null ? null : var.database_manage_master_user_password
  master_user_secret_kms_key_id = local.is_replica ? null : var.database_master_user_secret_kms_key_id

  vpc_security_group_ids = compact(
    concat(
      [join("", aws_security_group.default[*].id)],
      var.associate_security_group_ids
    )
  )

  db_subnet_group_name = local.db_subnet_group_name
  availability_zone    = local.availability_zone

  ca_cert_identifier          = var.ca_cert_identifier
  parameter_group_name        = length(var.parameter_group_name) > 0 ? var.parameter_group_name : join("", aws_db_parameter_group.default[*].name)
  option_group_name           = length(var.option_group_name) > 0 ? var.option_group_name : join("", aws_db_option_group.default[*].name)
  license_model               = var.license_model
  multi_az                    = var.multi_az
  storage_type                = var.storage_type
  iops                        = var.iops
  storage_throughput          = var.storage_type == "gp3" ? var.storage_throughput : null
  publicly_accessible         = var.publicly_accessible
  snapshot_identifier         = var.snapshot_identifier
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  tags                        = module.this.tags
  deletion_protection         = var.deletion_protection
  final_snapshot_identifier   = length(var.final_snapshot_identifier) > 0 ? var.final_snapshot_identifier : module.final_snapshot_label.id
  replicate_source_db         = var.replicate_source_db
  timezone                    = var.timezone

  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  dynamic "restore_to_point_in_time" {
    for_each = var.snapshot_identifier == null && var.restore_to_point_in_time != null ? [1] : []

    content {
      restore_time                             = lookup(var.restore_to_point_in_time, "restore_time", null)
      source_db_instance_identifier            = lookup(var.restore_to_point_in_time, "source_db_instance_identifier", null)
      source_db_instance_automated_backups_arn = lookup(var.restore_to_point_in_time, "source_db_instance_automated_backups_arn", null)
      source_dbi_resource_id                   = lookup(var.restore_to_point_in_time, "source_dbi_resource_id", null)
      use_latest_restorable_time               = lookup(var.restore_to_point_in_time, "use_latest_restorable_time", null)
    }
  }

  depends_on = [
    aws_db_subnet_group.default,
    aws_security_group.default,
    aws_db_parameter_group.default,
    aws_db_option_group.default
  ]

  lifecycle {
    ignore_changes = [
      snapshot_identifier, # if created from a snapshot, will be non-null at creation, but null afterwards
    ]
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}

resource "aws_db_parameter_group" "default" {
  count = length(var.parameter_group_name) == 0 && module.this.enabled ? 1 : 0

  name_prefix = "${module.this.id}${module.this.delimiter}"
  family      = var.db_parameter_group
  tags        = module.this.tags

  dynamic "parameter" {
    for_each = var.db_parameter
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_option_group" "default" {
  count = length(var.option_group_name) == 0 && module.this.enabled ? 1 : 0

  name_prefix          = "${module.this.id}${module.this.delimiter}"
  engine_name          = var.engine
  major_engine_version = local.major_engine_version
  tags                 = module.this.tags

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
  }
}

resource "aws_db_subnet_group" "default" {
  count = module.this.enabled && local.subnet_ids_provided && !local.db_subnet_group_name_provided ? 1 : 0

  name       = module.this.id
  subnet_ids = var.subnet_ids
  tags       = module.this.tags
}

resource "aws_security_group" "default" {
  count = module.this.enabled ? 1 : 0

  name        = module.this.id
  description = "Allow inbound traffic from the security groups"
  vpc_id      = var.vpc_id
  tags        = module.this.tags
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count = module.this.enabled ? length(var.security_group_ids) : 0

  description              = "Allow inbound traffic from existing Security Groups"
  type                     = "ingress"
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  source_security_group_id = var.security_group_ids[count.index]
  security_group_id        = join("", aws_security_group.default[*].id)
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count = module.this.enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = var.database_port
  to_port           = var.database_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default[*].id)
}

resource "aws_security_group_rule" "egress" {
  count             = module.this.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default[*].id)
}

module "dns_host_name" {
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.12.2"

  enabled  = length(var.dns_zone_id) > 0 && module.this.enabled
  dns_name = var.host_name
  zone_id  = var.dns_zone_id
  records  = coalescelist(aws_db_instance.default[*].address, [""])

  context = module.this.context
}
