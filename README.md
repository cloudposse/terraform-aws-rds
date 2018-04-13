# terraform-aws-rds [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-rds.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-rds)

Terraform module to provision AWS [`RDS`](https://aws.amazon.com/rds/) instances


The module will create:

* DB instance (MySQL, Postgres, SQL Server, Oracle)
* DB Parameter Group
* DB Subnet Group
* DB Security Group
* DNS Record in Route53 for the DB endpoint


## Inputs

- `stage` - The deployment stage (_e.g._ `prod`, `staging`, `dev`)
- `namespace` - The namespace of the application the DB instance belongs to (_e.g._ `global`, `shared`, or the name of your company like `cloudposse`)
- `name` - The name of the application the DB instance belongs to
- `dns_zone_id` - The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name
- `host_name` - The DB host name created in Route53
- `security_group_ids` - The IDs of the security groups from which to allow `ingress` traffic to the DB instance
- `database_name` -  (Optional) The name of the database to create when the DB instance is created
- `database_user` - (Required unless a `snapshot_identifier` or `replicate_source_db` is provided) Username for the master DB user
- `database_password` - (Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user
- `database_port` - Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids`
- `multi_az` - Default `false`. Set to `true` for a multi-AZ deployment (recommended for production)
- `storage_type` - One of `standard` (magnetic), `gp2` (general purpose SSD), or `io1` (provisioned IOPS SSD). Default `standard` (magnetic)
- `iops` - The amount of provisioned IOPS. Setting this implies a storage_type of `io1`. Default is `0` if rds storage type is not `io1`
- `allocated_storage` - The number of GBs to allocate for DB storage. Must be an integer, _e.g._ `10`
- `storage_encrypted` - (Optional) Specifies whether the DB instance is encrypted. The default is false if not specified.
- `engine` - Engine type, such as `mysql` or `postgres`
- `engine_version` - DB Engine version, _e.g._ `9.5.4` for `Postgres`
- `instance_class` - Instance class, _e.g._ `db.t2.micro`
- `db_parameter_group` - DB Parameter Group, _e.g._ `mysql5.6` for MySQL, `postgres9.5` for `Postgres`
- `publicly_accessible` - Determines if the DB instance can be publicly accessed from the Internet. Default `false`
- `subnet_ids` - List of subnets IDs in the VPC, _e.g._ `["sb-1234567890", "sb-0987654321"]`
- `vpc_id` - VPC ID the DB instance will be connected to
- `auto_minor_version_upgrade` - Automatically upgrade minor version of the DB (eg. from Postgres 9.5.3 to Postgres 9.5.4). Default `true`
- `allow_major_version_upgrade` - Allow upgrading of major version of database. Default `false`. **Important**: if you are using a snapshot for creating an instance, this option should be set to `true` (if engine versions specified in the manifest and in the snapshot are different)
- `apply_immediately` - Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default `false`
- `maintenance_window` - The window to perform maintenance in. Default `"Mon:03:00-Mon:04:00"`
- `skip_final_snapshot` - If `true` (default), DB won't be backed up before deletion
- `copy_tags_to_snapshot` - Copy all tags from RDS database to snapshot. Default `true`
- `backup_retention_period` - Backup retention period in days (default `0`). Must be `> 0` to enable backups
- `backup_window` - When to perform DB snapshots. Default `"22:00-03:00"`. Can't overlap with the maintenance window
- `db_parameter` -  A list of DB parameters to apply. Note that parameters may differ from a family to an other
- `snapshot_identifier` - Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: `rds:production-2015-06-26-06-05`
- `final_snapshot_identifier` - Specifies whether or not to create a final snapshot for this database when destroing. This option **must** be set if `skip_final_snapshot` = `false`. E.g.: `"dbname-final-snapshot-${md5(timestamp())}"`
- `parameter_group_name` - (Optional) Name of the DB parameter group to associate (e.g. `mysql-5-6`)


## Outputs

- `instance_id` - ID of the instance
- `instance_address` - Address of the instance
- `instance_endpoint` - DNS Endpoint of the instance
- `subnet_group_id` - ID of the Subnet Group
- `security_group_id` - ID of the Security Group
- `parameter_group_id` - ID of the Parameter Group
- `hostname` - DNS host name of the instance


## Usage

```hcl
module "rds_instance" {
      source                      = "git::https://github.com/cloudposse/terraform-aws-rds.git?ref=master"
      namespace                   = "cp"
      stage                       = "prod"
      name                        = "app"
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

      db_parameter                = [
        { name  = "myisam_sort_buffer_size"   value = "1048576" },
        { name  = "sort_buffer_size"          value = "2097152" },
      ]
}
```


## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-rds/issues), send us an [email](mailto:hello@cloudposse.com) or reach out to us on [Gitter](https://gitter.im/cloudposse/).


## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-rds/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing `terraform-aws-rds`, we would love to hear from you! Shoot us an [email](mailto:hello@cloudposse.com).

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

**NOTE:** Be sure to merge the latest from "upstream" before making a pull request!


## License

[APACHE 2.0](LICENSE) © 2018 [Cloud Posse, LLC](https://cloudposse.com)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.


## About

`terraform-aws-rds` is maintained and funded by [Cloud Posse, LLC][website].

![Cloud Posse](https://cloudposse.com/logo-300x69.png)


Like it? Please let us know at <hello@cloudposse.com>

We love [Open Source Software](https://github.com/cloudposse/)!

See [our other projects][community]
or [hire us][hire] to help build your next cloud platform.

  [website]: https://cloudposse.com/
  [community]: https://github.com/cloudposse/
  [hire]: https://cloudposse.com/contact/


## Contributors

| [![Erik Osterman][erik_img]][erik_web]<br/>[Erik Osterman][erik_web] | [![Andriy Knysh][andriy_img]][andriy_web]<br/>[Andriy Knysh][andriy_web] |[![Igor Rodionov][igor_img]][igor_web]<br/>[Igor Rodionov][igor_img]
|-------------------------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------|

[erik_img]: http://s.gravatar.com/avatar/88c480d4f73b813904e00a5695a454cb?s=144
[erik_web]: https://github.com/osterman/
[andriy_img]: https://avatars0.githubusercontent.com/u/7356997?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
[andriy_web]: https://github.com/aknysh/
[igor_img]: http://s.gravatar.com/avatar/bc70834d32ed4517568a1feb0b9be7e2?s=144
[igor_web]: https://github.com/goruha/
