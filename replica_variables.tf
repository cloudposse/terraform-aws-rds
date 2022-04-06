variable "replica_instance_class" {
  type        = string
  description = "Class of RDS instance"
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
}

variable "replica_count" {
  type        = string
  description = "no of read replica"
  default = "0"
}