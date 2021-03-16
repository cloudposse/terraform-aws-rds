provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.21.1"

  cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.38.0"

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
  instance_class       = var.instance_class
  db_parameter_group   = var.db_parameter_group
  publicly_accessible  = var.publicly_accessible
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.subnets.private_subnet_ids
  security_group_ids   = [module.vpc.vpc_default_security_group_id]
  apply_immediately    = var.apply_immediately
  availability_zone    = var.availability_zone
  db_subnet_group_name = var.db_subnet_group_name

  db_parameter = [
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
