module "rds_instance" {
  source                      = "git::https://github.com/cloudposse/terraform-aws-rds.git?ref=master"
  namespace                   = "eg"
  stage                       = "prod"
  name                        = "app"
  enabled                     = "true"
  dns_zone_id                 = "Z89FN1IW975KPE"
  host_name                   = "db"
  security_group_ids          = ["sg-xxxxxxxx"]
  database_name               = "wordpress"
  database_user               = "admin"
  database_password           = "xxxxxxxxxxxx"
  database_port               = 3306
  multi_az                    = "true"
  storage_type                = "gp2"
  allocated_storage           = "100"
  storage_encrypted           = "true"
  engine                      = "mysql"
  engine_version              = "5.7.17"
  instance_class              = "db.t2.medium"
  db_parameter_group          = "mysql5.6"
  parameter_group_name        = "mysql-5-6"
  publicly_accessible         = "false"
  subnet_ids                  = ["sb-xxxxxxxxx", "sb-xxxxxxxxx"]
  vpc_id                      = "vpc-xxxxxxxx"
  snapshot_identifier         = "rds:production-2015-06-26-06-05"
  auto_minor_version_upgrade  = "true"
  allow_major_version_upgrade = "false"
  apply_immediately           = "false"
  maintenance_window          = "Mon:03:00-Mon:04:00"
  skip_final_snapshot         = "false"
  copy_tags_to_snapshot       = "true"
  backup_retention_period     = 7
  backup_window               = "22:00-03:00"

  db_parameter = [
    {
      name = "myisam_sort_buffer_size"

      value = "1048576"
    },
    {
      name = "sort_buffer_size"

      value = "2097152"
    },
  ]
}
