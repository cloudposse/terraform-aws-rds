# AWS KMS alias used for encryption/decryption of SSM secure strings
variable "kms_alias_name_ssm" {
  type        = string
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}

variable "ssm_parameters_enabled" {
  type        = bool
  default     = false
  description = "If `true` create SSM keys for the database user and password."
}

variable "ssm_key_format" {
  type        = string
  default     = "/%v/%v/%v"
  description = "SSM path format. The values will will be used in the following order: `var.ssm_key_prefix`, `module.this.name`, `var.ssm_key_*`"
}

variable "ssm_key_prefix" {
  type        = string
  default     = "rds"
  description = "SSM path prefix. Omit the leading forward slash `/`."
}

variable "save_parameter_ssm_map_default" {
  type = any
  default = {
    user = {
      suffix      = "admin/db_user"
      description = "RDS DB user"
      type        = "String"
      overwrite   = true
    }
    password = {
      suffix      = "admin/db_password"
      description = "RDS DB password"
      type        = "SecureString"
      overwrite   = true
    }
    hostname = {
      suffix      = "admin/db_hostname"
      description = "RDS DB hostname"
      type        = "String"
      overwrite   = true
    }
    port = {
      suffix      = "admin/db_port"
      description = "RDS DB port"
      type        = "String"
      overwrite   = true
    }
  }
  description = "The map of ssm keys to the `aws_ssm_parameter` resource. The `description`, `type`, and `overwrite` are passed directly to that resource. The `suffix` is the last value in the `var.ssm_key_format`. If the `type = \"SecureString\"` then the `key_id = var.kms_alias_name_ssm`."
}

variable "save_parameter_ssm_map_merge" {
  type        = any
  default     = {}
  description = "This map will be merged with `var.save_parameter_ssm_map_default` so the defaults can be reused while only overwriting a handful of keys."
}

locals {
  ssm_parameters_enabled = local.enabled && var.ssm_parameters_enabled

  # This will merge the save_parameter_ssm_map defaults with the save_parameter_ssm_map_merge
  # This is more of a deep merge than a simple merge. A simple merge would require all of the
  # same keys.
  save_parameter_ssm_map = {
    for k, v in var.save_parameter_ssm_map_default :
    k => merge(v, try(var.save_parameter_ssm_map_merge[k], {}))
  }

  value_parameter_map = {
    user     = local.database_user
    password = local.database_password
    hostname = module.dns_host_name.hostname
    port     = var.database_port
  }
}

resource "aws_ssm_parameter" "rds_database" {
  for_each = local.ssm_parameters_enabled ? local.save_parameter_ssm_map : {}

  name        = format(var.ssm_key_format, var.ssm_key_prefix, module.this.name, each.value.suffix)
  value       = local.value_parameter_map[each.key]
  description = each.value.description
  type        = each.value.type
  key_id      = each.value.type == "SecureString" ? var.kms_alias_name_ssm : null
  overwrite   = each.value.overwrite
}

output "rds_database_ssm_key_prefix" {
  value       = local.ssm_parameters_enabled ? format(var.ssm_key_format, var.ssm_key_prefix, module.this.name, "") : null
  description = "SSM prefix"
}
