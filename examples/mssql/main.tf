provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.1.1"

  ipv4_primary_cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.4.1"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "rds_instance" {
  source             = "../../"
  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  database_name      = var.database_name
  database_user      = var.database_user
  database_password  = var.database_password
  database_port      = var.database_port
  multi_az           = var.multi_az
  storage_type       = var.storage_type
  allocated_storage  = var.allocated_storage
  storage_encrypted  = var.storage_encrypted
  engine             = var.engine
  engine_version     = var.engine_version
  instance_class     = var.instance_class
  db_parameter_group = var.db_parameter_group

  publicly_accessible = var.publicly_accessible
  allowed_cidr_blocks = ["172.16.0.0/16"]
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.subnets.private_subnet_ids
  security_group_ids  = [module.vpc.vpc_default_security_group_id]
  apply_immediately   = var.apply_immediately

}
