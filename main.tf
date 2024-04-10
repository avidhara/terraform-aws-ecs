resource "aws_ecs_cluster" "this" {
  count = var.create ? 1 : 0

  name = var.name

  dynamic "configuration" {
    for_each = var.configuration
    content {

      dynamic "execute_command_configuration" {
        for_each = try([configuration.value.execute_command_configuration], [])
        content {
          #checkov:skip=CKV_AWS_224: Default KMS key not enabled
          kms_key_id = try(execute_command_configuration.value.kms_key_id, null)
          logging    = try(execute_command_configuration.value.logging, "DEFAULT")
          dynamic "log_configuration" {
            for_each = try([execute_command_configuration.value.log_configuration], [])
            content {
              cloud_watch_encryption_enabled = try(log_configuration.value.cloud_watch_encryption_enabled, null)
              cloud_watch_log_group_name     = try(log_configuration.value.cloud_watch_log_group_name, null)
              s3_bucket_name                 = try(log_configuration.value.s3_bucket_name, null)
              s3_bucket_encryption_enabled   = try(log_configuration.value.s3_bucket_encryption_enabled, null)
              s3_key_prefix                  = try(log_configuration.value.s3_key_prefix, null)
            }
          }
        }
      }

    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.service_connect_defaults
    content {
      namespace = service_connect_defaults.value.namespace
    }
  }
  #CKV_AWS_65: ContainerInsights enabled on ECS cluster
  dynamic "setting" {
    for_each = var.setting
    content {
      name  = try(setting.value.name, "containerInsights")
      value = try(setting.value.value, "enabled")
    }
  }
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  count = var.create ? 1 : 0

  cluster_name = aws_ecs_cluster.this[0].name

  capacity_providers = var.capacity_providers

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      base              = try(default_capacity_provider_strategy.value.base, 0)
      weight            = try(default_capacity_provider_strategy.value.weight, 0)
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
    }

  }
}


#### IAM Role ####

data "aws_iam_policy_document" "task_exec_assume" {
  count = var.create ? 1 : 0

  statement {
    sid     = "ECSTaskExecutionAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_exec" {
  count = var.create ? 1 : 0

  name        = format("%s-task-exec-role", var.name)
  description = format("Task execution role for %s", var.name)

  assume_role_policy    = data.aws_iam_policy_document.task_exec_assume[0].json
  force_detach_policies = true

  tags = var.tags
}

# resource "aws_iam_role_policy_attachment" "task_exec_additional" {
#   for_each = { for k, v in var.task_exec_iam_role_policies : k => v if local.create_task_exec_iam_role }

#   role       = aws_iam_role.task_exec[0].name
#   policy_arn = each.value
# }


data "aws_iam_policy_document" "task_exec" {
  count = var.create ? 1 : 0

  # Pulled from AmazonECSTaskExecutionRolePolicy
  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  # Pulled from AmazonECSTaskExecutionRolePolicy
  statement {
    sid = "ECR"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = [1]

    content {
      sid       = "GetSSMParams"
      actions   = ["ssm:GetParameters"]
      resources = ["arn:aws:ssm:*:*:parameter/*"]
    }
  }

  dynamic "statement" {
    for_each = [1]

    content {
      sid       = "GetSecrets"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["arn:aws:secretsmanager:*:*:secret:*"]
    }
  }
}

resource "aws_iam_policy" "task_exec" {
  count = var.create ? 1 : 0

  name        = format("%s-task-exec-policy", var.name)
  description = format("execution role IAM policy for %s", var.name)
  policy      = data.aws_iam_policy_document.task_exec[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "task_exec" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.task_exec[0].name
  policy_arn = aws_iam_policy.task_exec[0].arn
}


resource "aws_iam_role_policy_attachment" "task_exec_managed" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.task_exec[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
