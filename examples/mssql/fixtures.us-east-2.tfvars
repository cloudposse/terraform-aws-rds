region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "rds-mssql"

deletion_protection = false

database_name = null

database_user = "db_user"

database_password = "db_password"

database_port = 1433

multi_az = false

storage_type = "standard"

storage_encrypted = false

allocated_storage = 20

# Microsoft SQL Server on Amazon RDS
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html
engine = "sqlserver-ex"

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html#SQLServer.Concepts.General.VersionSupport
engine_version = "14.00.1000.169.v1"

#major_engine_version = "5.7"
major_engine_version = "14.00.1000.169.v1"

instance_class = "db.t2.small"

#db_parameter_group = "mysql5.7"
db_parameter_group = "sqlserver-ex-14.0"

publicly_accessible = false

apply_immediately = true
