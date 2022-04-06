variable "replica_instance_class" {
  type        = string
  default = "db.t3.micro"
  description = "Class of RDS instance"
}

variable "replica_count" {
  type        = string
  description = "no of read replica"
  default = "0"
}