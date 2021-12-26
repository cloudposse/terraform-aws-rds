provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.28.1"

  cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.39.8"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "rds_instance" {
  source               = "../../"
  database_name        = var.database_name
  database_user        = var.database_user
  database_password    = var.database_password
  database_port        = var.database_port
  multi_az             = var.multi_az
  storage_type         = var.storage_type
  allocated_storage    = var.allocated_storage
  storage_encrypted    = var.storage_encrypted
  engine               = var.engine
  engine_version       = var.engine_version
  major_engine_version = var.major_engine_version
  instance_class       = var.instance_class
  db_parameter_group   = var.db_parameter_group
  publicly_accessible  = var.publicly_accessible
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.subnets.private_subnet_ids
  security_group_ids   = [module.vpc.vpc_default_security_group_id]
  apply_immediately    = var.apply_immediately
  availability_zone    = var.availability_zone
  db_subnet_group_name = var.db_subnet_group_name
  role_associations = local.s3_integration_enabled ? {
    S3_INTEGRATION = module.role.arn
  } : {}

  db_parameter = local.s3_integration_enabled ? [] : [ # the S3 integration test relies on MySQL
    {
      name         = "myisam_sort_buffer_size"
      value        = "1048576"
      apply_method = "immediate"
    },
    {
      name         = "sort_buffer_size"
      value        = "2097152"
      apply_method = "immediate"
    }
  ]

  context = module.this.context
}

# The remainder of this configuration has to do with creating an S3 integration.
# This is to test var.role_associations.
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance_role_association
# and https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/oracle-s3-integration.html
locals {
  s3_integration_enabled = module.this.enabled && var.s3_integration_enabled
  s3_integration_actions = [
    "s3:ListBucket",
    "s3:GetObject",
    "s3:PutObject"
  ]
  # Workaround for principal ARN in S3 Bucket policy not being known until apply
  s3_integration_bucket_arn = "arn:${join("", data.aws_partition.current.*.partition)}:s3:::${module.this.id}"
  s3_integration_role_arn = "arn:${join("", data.aws_partition.current.*.partition)}:iam::${join("", data.aws_caller_identity.current.*.account_id)}:role/${module.this.id}"
}

data "aws_caller_identity" "current" {
  count = local.s3_integration_enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.s3_integration_enabled ? 1 : 0
}

data "aws_iam_policy_document" "bucket_policy" {
  count = local.s3_integration_enabled ? 1 : 0

  statement {
    sid = "AllowIntegrationRoleS3Access"

    actions = local.s3_integration_actions

    resources = [
      local.s3_integration_bucket_arn,
      "${local.s3_integration_bucket_arn}/*"
    ]
    effect    = "Allow"

    principals {
      identifiers = [local.s3_integration_role_arn]
      type = "AWS"
    }
  }
}

module "s3_bucket" {
  source = "cloudposse/s3-bucket/aws"
  version = "0.44.1"

  enabled = local.s3_integration_enabled

  acl = "private"
  policy = join("", data.aws_iam_policy_document.bucket_policy.*.json)

  context = module.this.context
}

data "aws_iam_policy_document" "role_policy" {
  count = local.s3_integration_enabled ? 1 : 0

  statement {
    sid = "AllowS3Access"

    actions = local.s3_integration_actions

    resources = [
      local.s3_integration_bucket_arn,
      "${local.s3_integration_bucket_arn}/*"
    ]
    effect    = "Allow"
  }
}

module "role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.14.0"

  enabled = local.s3_integration_enabled

  policy_description = "Allow RDS Access to S3 (S3_INTEGRATION)."
  role_description   = "Allow IAM Role assumed by RDS to perform S3 Actions (S3_INTEGRATION)."

  principals = {
    Service = ["rds.amazonaws.com"]
  }

  policy_documents = [
    join("", data.aws_iam_policy_document.role_policy.*.json)
  ]

  context = module.this.context
}