region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

environment = "ue2"

stage = "test"

name = "rds-s3-integration"

deletion_protection = false

database_name = "testdb"

database_user = "oraadmin"

database_password = "admin_password"

database_port = 1521

multi_az = false

storage_type = "standard"

storage_encrypted = false

allocated_storage = 20

engine = "oracle-ee"

engine_version = "12.1.0.2.v25"

major_engine_version = "12.1"

instance_class = "db.t3.small"

db_parameter_group = "oracle-ee-12.1"

publicly_accessible = false

apply_immediately = true

s3_integration_enabled = true
