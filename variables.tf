variable "create" {
  type        = bool
  description = "(Optional) Whether to create the ECS cluster (if set to false, it will only create a service and task definition)"
  default     = true
}

variable "name" {
  type        = string
  description = "(Required) Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  nullable    = false
}

variable "configuration" {
  type = list(object({
    execute_command_configuration = object({
      kms_key_id = optional(string)
      logging    = optional(string)
      log_configuration = optional(object({
        cloud_watch_encryption_enabled = optional(bool)
        cloud_watch_log_group_name     = optional(string)
        s3_bucket_name                 = optional(string)
        s3_bucket_encryption_enabled   = optional(bool)
        s3_key_prefix                  = optional(string)
      }))
    })
  }))
  description = <<_EOT
    (Optional) The details of the execute command configuration. Detailed below.
    - execute_command_configuration - (Optional) The details of the execute command configuration. Detailed below.
    - kms_key_id - (Optional) The KMS key that the Amazon ECS container agent uses to encrypt the data between the local agent and the Amazon ECS service. If the key is not specified, the data is encrypted using the Amazon ECS-Managed encryption key. If a key is specified, the other settings in the execute_command_configuration block are required.
    - logging - (Optional) The log configuration for the execute command configuration. Detailed below.
    - log_configuration - (Optional) The log configuration for the execute command configuration. Detailed below.
    - cloud_watch_encryption_enabled - (Optional) Whether or not to enable encryption on the CloudWatch logs. Default is false.
    - cloud_watch_log_group_name - (Optional) The name of the CloudWatch log group to send logs to.
    - s3_bucket_name - (Optional) The name of the S3 bucket to send logs to.
    - s3_bucket_encryption_enabled - (Optional) Whether or not to enable encryption on the S3 bucket. Default is false.
    - s3_key_prefix - (Optional) The prefix to use when storing logs in the S3 bucket.
    _EOT
  default     = []
}

variable "service_connect_defaults" {
  type = list(object({
    namespace = string
  }))
  description = <<_EOT
  (Required) The ARN of the aws_service_discovery_http_namespace that's used when you create a service and don't specify a Service Connect configuration."
  - namespace - (Required) The ARN of the aws_service_discovery_http_namespace that's used when you create a service and don't specify a Service Connect configuration.
  _EOT
  default     = []
}

variable "setting" {
  type = list(object({
    name  = string
    value = string
  }))
  description = <<_EOT
    (Optional) The settings to use when creating the cluster. Detailed below.
    - name - (Required) The name of the setting.
    - value - (Required) The value of the setting.
    _EOT
  default = [{
    name  = "containerInsights"
    value = "enabled"
  }]
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Key-value mapping of resource tags"
  default     = {}
}

######## Cluster Capacity Providers ########

variable "capacity_providers" {
  type        = list(string)
  description = "(Optional) Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  default     = ["FARGATE"]
}

variable "default_capacity_provider_strategy" {
  type = list(object({
    base              = optional(number)
    weight            = optional(number)
    capacity_provider = string
  }))
  description = <<_EOT
    (Optional) The default capacity provider strategy for the cluster. The default capacity provider strategy is used when services or tasks are run without a specified launch type or capacity provider strategy. Detailed below.
    - base - (Optional) The base value designates how many tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.
    - weight - (Optional) The weight value designates the relative percentage of the total number of tasks launched that should use the specified capacity provider. The weight value is taken into consideration after the base value, if defined, is satisfied.
    - capacity_provider - (Required) The short name of the capacity provider.
    _EOT
  default     = []
}
