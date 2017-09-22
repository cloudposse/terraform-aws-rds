variable "stage" {
  default = "default"
}

variable "namespace" {
  default = "global"
}

variable "name" {
  default = "app"
}

variable "dns_zone_id" {}

variable "host_name" {
  default = "db"
}

variable "security_group_ids" {
  type = "list"
}

variable "database_name" {}

variable "database_user" {}

variable "database_password" {}

variable "database_port" {}

variable "multi_az" {
  description = "Set to true if multi AZ deployment must be supported"
  default     = false
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
  default     = "standard"
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. Default is 0 if rds storage type is not 'io1'"
  default     = "0"
}

variable "allocated_storage" {
  description = "The allocated storage in GBs"

  # Number, e.g. 10
}

variable "engine" {
  description = "Database engine type"

  # http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
  # - mysql
  # - postgres
  # - oracle-*
  # - sqlserver-*
}

variable "engine_version" {
  description = "Database engine version, depends on engine type"

  # http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
}

variable "instance_class" {
  description = "Class of RDS instance"

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
}

# This is for custom parameters to be passed to the DB
# We're "cloning" default ones, but we need to specify which should be copied
variable "db_parameter_group" {
  description = "Parameter group, depends on DB engine used"

  # "mysql5.6"
  # "postgres9.5"
}

variable "publicly_accessible" {
  description = "Determines if database can be publicly available (NOT recommended)"
  default     = false
}

variable "subnet_ids" {
  description = "List of subnets for the DB"
  type        = "list"
}

variable "vpc_id" {
  type = "string"
}

variable "auto_minor_version_upgrade" {
  description = "Allow automated minor version upgrade"
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrade"
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC "
  default     = "Mon:03:00-Mon:04:00"
}

variable "skip_final_snapshot" {
  description = "If true (default), no snapshot will be made before deleting DB"
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags from DB to a snapshot"
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days. Must be > 0 to enable backups"
  default     = 0
}

variable "backup_window" {
  description = "When AWS can perform DB snapshots, can't overlap with maintenance window"
  default     = "22:00-03:00"
}

variable "delimiter" {
  type    = "string"
  default = "-"
}

variable "attributes" {
  type    = "list"
  default = []
}

variable "tags" {
  type    = "map"
  default = {}
}
