# Terraform Module for ECS Cluster

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.40 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_policy.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_exec_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | (Optional) Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE\_SPOT. | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | (Optional) The details of the execute command configuration. Detailed below.<br>    - execute\_command\_configuration - (Optional) The details of the execute command configuration. Detailed below.<br>    - kms\_key\_id - (Optional) The KMS key that the Amazon ECS container agent uses to encrypt the data between the local agent and the Amazon ECS service. If the key is not specified, the data is encrypted using the Amazon ECS-Managed encryption key. If a key is specified, the other settings in the execute\_command\_configuration block are required.<br>    - logging - (Optional) The log configuration for the execute command configuration. Detailed below.<br>    - log\_configuration - (Optional) The log configuration for the execute command configuration. Detailed below.<br>    - cloud\_watch\_encryption\_enabled - (Optional) Whether or not to enable encryption on the CloudWatch logs. Default is false.<br>    - cloud\_watch\_log\_group\_name - (Optional) The name of the CloudWatch log group to send logs to.<br>    - s3\_bucket\_name - (Optional) The name of the S3 bucket to send logs to.<br>    - s3\_bucket\_encryption\_enabled - (Optional) Whether or not to enable encryption on the S3 bucket. Default is false.<br>    - s3\_key\_prefix - (Optional) The prefix to use when storing logs in the S3 bucket. | <pre>list(object({<br>    execute_command_configuration = object({<br>      kms_key_id = optional(string)<br>      logging    = optional(string)<br>      log_configuration = optional(object({<br>        cloud_watch_encryption_enabled = optional(bool)<br>        cloud_watch_log_group_name     = optional(string)<br>        s3_bucket_name                 = optional(string)<br>        s3_bucket_encryption_enabled   = optional(bool)<br>        s3_key_prefix                  = optional(string)<br>      }))<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | (Optional) Whether to create the ECS cluster (if set to false, it will only create a service and task definition) | `bool` | `true` | no |
| <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy) | (Optional) The default capacity provider strategy for the cluster. The default capacity provider strategy is used when services or tasks are run without a specified launch type or capacity provider strategy. Detailed below.<br>    - base - (Optional) The base value designates how many tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.<br>    - weight - (Optional) The weight value designates the relative percentage of the total number of tasks launched that should use the specified capacity provider. The weight value is taken into consideration after the base value, if defined, is satisfied.<br>    - capacity\_provider - (Required) The short name of the capacity provider. | <pre>list(object({<br>    base              = optional(number)<br>    weight            = optional(number)<br>    capacity_provider = string<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | n/a | yes |
| <a name="input_service_connect_defaults"></a> [service\_connect\_defaults](#input\_service\_connect\_defaults) | (Required) The ARN of the aws\_service\_discovery\_http\_namespace that's used when you create a service and don't specify a Service Connect configuration."<br>  - namespace - (Required) The ARN of the aws\_service\_discovery\_http\_namespace that's used when you create a service and don't specify a Service Connect configuration. | <pre>list(object({<br>    namespace = string<br>  }))</pre> | `[]` | no |
| <a name="input_setting"></a> [setting](#input\_setting) | (Optional) The settings to use when creating the cluster. Detailed below.<br>    - name - (Required) The name of the setting.<br>    - value - (Required) The value of the setting. | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "containerInsights",<br>    "value": "enabled"<br>  }<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value mapping of resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN that identifies the cluster |
| <a name="output_id"></a> [id](#output\_id) | ARN that identifies the cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
