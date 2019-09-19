## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allocated_storage | The allocated storage in GBs | number | - | yes |
| allow_major_version_upgrade | Allow major version upgrade | bool | `false` | no |
| apply_immediately | Specifies whether any database modifications are applied immediately, or during the next maintenance window | bool | `false` | no |
| associate_security_group_ids | The IDs of the existing security groups to associate with the DB instance | list(string) | `<list>` | no |
| attributes | Additional attributes (e.g. `1`) | list(string) | `<list>` | no |
| auto_minor_version_upgrade | Allow automated minor version upgrade (e.g. from Postgres 9.5.3 to Postgres 9.5.4) | bool | `true` | no |
| backup_retention_period | Backup retention period in days. Must be > 0 to enable backups | number | `0` | no |
| backup_window | When AWS can perform DB snapshots, can't overlap with maintenance window | string | `22:00-03:00` | no |
| copy_tags_to_snapshot | Copy tags from DB to a snapshot | bool | `true` | no |
| database_name | The name of the database to create when the DB instance is created | string | - | yes |
| database_password | (Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user | string | `` | no |
| database_port | Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids` | number | - | yes |
| database_user | (Required unless a `snapshot_identifier` or `replicate_source_db` is provided) Username for the master DB user | string | `` | no |
| db_options | A list of DB options to apply with an option group. Depends on DB engine | object | `<list>` | no |
| db_parameter | A list of DB parameters to apply. Note that parameters may differ from a DB family to another | object | `<list>` | no |
| db_parameter_group | Parameter group, depends on DB engine used | string | - | yes |
| deletion_protection | Set to true to enable deletion protection on the RDS instance | bool | `false` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage` and `attributes` | string | `-` | no |
| dns_zone_id | The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name | string | `` | no |
| enabled | Set to false to prevent the module from creating any resources | bool | `true` | no |
| engine | Database engine type | string | - | yes |
| engine_version | Database engine version, depends on engine type | string | - | yes |
| final_snapshot_identifier | Final snapshot identifier e.g.: some-db-final-snapshot-2019-06-26-06-05 | string | `` | no |
| host_name | The DB host name created in Route53 | string | `db` | no |
| instance_class | Class of RDS instance | string | - | yes |
| iops | The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. Default is 0 if rds storage type is not 'io1' | number | `0` | no |
| kms_key_arn | The ARN of the existing KMS key to encrypt storage | string | `` | no |
| license_model | License model for this DB. Optional, but required for some DB Engines. Valid values: license-included | bring-your-own-license | general-public-license | string | `` | no |
| maintenance_window | The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC | string | `Mon:03:00-Mon:04:00` | no |
| major_engine_version | Database MAJOR engine version, depends on engine type | string | `` | no |
| max_allocated_storage | The upper limit to which RDS can automatically scale the storage in GBs | number | `0` | no |
| multi_az | Set to true if multi AZ deployment must be supported | bool | `false` | no |
| name | The Name of the application or solution  (e.g. `bastion` or `portal`) | string | - | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | string | `` | no |
| option_group_name | Name of the DB option group to associate | string | `` | no |
| parameter_group_name | Name of the DB parameter group to associate | string | `` | no |
| publicly_accessible | Determines if database can be publicly available (NOT recommended) | bool | `false` | no |
| security_group_ids | The IDs of the security groups from which to allow `ingress` traffic to the DB instance | list(string) | `<list>` | no |
| skip_final_snapshot | If true (default), no snapshot will be made before deleting DB | bool | `true` | no |
| snapshot_identifier | Snapshot identifier e.g: rds:production-2019-06-26-06-05. If specified, the module create cluster from the snapshot | string | `` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `` | no |
| storage_encrypted | (Optional) Specifies whether the DB instance is encrypted. The default is false if not specified | bool | `false` | no |
| storage_type | One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD) | string | `standard` | no |
| subnet_ids | List of subnets for the DB | list(string) | - | yes |
| tags | Additional tags (e.g. { BusinessUnit : ABC }) | map(string) | `<map>` | no |
| vpc_id | VPC ID the DB instance will be created in | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| hostname | DNS host name of the instance |
| instance_address | Address of the instance |
| instance_arn | ARN of the instance |
| instance_endpoint | DNS Endpoint of the instance |
| instance_id | ID of the instance |
| option_group_id | ID of the Option Group |
| parameter_group_id | ID of the Parameter Group |
| security_group_id | ID of the Security Group |
| subnet_group_id | ID of the Subnet Group |

