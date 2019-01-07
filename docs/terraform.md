## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allocated_storage | The allocated storage in GBs | string | - | yes |
| allow_major_version_upgrade | Allow major version upgrade | string | `false` | no |
| apply_immediately | Specifies whether any database modifications are applied immediately, or during the next maintenance window | string | `false` | no |
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| auto_minor_version_upgrade | Allow automated minor version upgrade (e.g. from Postgres 9.5.3 to Postgres 9.5.4) | string | `true` | no |
| backup_retention_period | Backup retention period in days. Must be > 0 to enable backups | string | `0` | no |
| backup_window | When AWS can perform DB snapshots, can't overlap with maintenance window | string | `22:00-03:00` | no |
| copy_tags_to_snapshot | Copy tags from DB to a snapshot | string | `true` | no |
| database_name | The name of the database to create when the DB instance is created | string | - | yes |
| database_password | (Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user | string | `` | no |
| database_port | Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids` | string | - | yes |
| database_user | (Required unless a `snapshot_identifier` or `replicate_source_db` is provided) Username for the master DB user | string | `` | no |
| db_parameter | A list of DB parameters to apply. Note that parameters may differ from a DB family to another | list | `<list>` | no |
| db_parameter_group | Parameter group, depends on DB engine used | string | - | yes |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage` and `attributes` | string | `-` | no |
| dns_zone_id | The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name | string | `` | no |
| enabled | Set to false to prevent the module from creating any resources | string | `true` | no |
| engine | Database engine type | string | - | yes |
| engine_version | Database engine version, depends on engine type | string | - | yes |
| final_snapshot_identifier | Final snapshot identifier e.g.: some-db-final-snapshot-2015-06-26-06-05 | string | `` | no |
| host_name | The DB host name created in Route53 | string | `db` | no |
| instance_class | Class of RDS instance | string | - | yes |
| iops | The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. Default is 0 if rds storage type is not 'io1' | string | `0` | no |
| maintenance_window | The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC | string | `Mon:03:00-Mon:04:00` | no |
| multi_az | Set to true if multi AZ deployment must be supported | string | `false` | no |
| name | The Name of the application or solution  (e.g. `bastion` or `portal`) | string | - | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | string | - | yes |
| parameter_group_name | Name of the DB parameter group to associate | string | `` | no |
| publicly_accessible | Determines if database can be publicly available (NOT recommended) | string | `false` | no |
| security_group_ids | he IDs of the security groups from which to allow `ingress` traffic to the DB instance | list | `<list>` | no |
| skip_final_snapshot | If true (default), no snapshot will be made before deleting DB | string | `true` | no |
| snapshot_identifier | Snapshot identifier e.g: rds:production-2015-06-26-06-05. If specified, the module create cluster from the snapshot | string | `` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| storage_encrypted | (Optional) Specifies whether the DB instance is encrypted. The default is false if not specified. | string | `false` | no |
| storage_type | One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). | string | `standard` | no |
| subnet_ids | List of subnets for the DB | list | - | yes |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`) | map | `<map>` | no |
| vpc_id | VPC ID the DB instance will be created in | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| hostname | DNS host name of the instance |
| instance_address | Address of the instance |
| instance_endpoint | DNS Endpoint of the instance |
| instance_id | ID of the instance |
| parameter_group_id | ID of the Parameter Group |
| security_group_id | ID of the Security Group |
| subnet_group_id | ID of the Subnet Group |

