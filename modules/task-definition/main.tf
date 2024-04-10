resource "aws_ecs_task_definition" "this" {
  family                = "service"
  container_definitions = var.container_definitions
  cpu                   = var.cpu
  execution_role_arn    = var.execution_role_arn

  dynamic "inference_accelerator" {
    for_each = var.inference_accelerator
    content {
      device_name = inference_accelerator.value.device_name
      device_type = inference_accelerator.value.device_type
    }
  }
  ipc_mode     = var.ipc_mode
  memory       = var.memory
  network_mode = var.network_mode

  dynamic "runtime_platform" {
    for_each = var.runtime_platform
    content {
      operating_system_family = try(runtime_platform.value.operating_system_family, "LINUX")
      cpu_architecture        = try(runtime_platform.value.cpu_architecture, "X86_64")
    }
  }
  pid_mode = var.pid_mode

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration
    content {
      container_name = proxy_configuration.value.container_name
      properties     = proxy_configuration.value.properties
      type           = try(proxy_configuration.value.type, "APPMESH")
    }
  }

  #   dynamic "ephemeral_storage " {
  #     for_each = var.ephemeral_storage
  #     content {
  #       size_in_gib = try(ephemeral_storage.value.size_in_gib, 21)
  #     }
  #   }

  requires_compatibilities = var.requires_compatibilities
  skip_destroy             = var.skip_destroy
  task_role_arn            = var.task_role_arn
  track_latest             = var.track_latest

  dynamic "volume" {
    for_each = var.volume
    content {
      name      = volume.value.name
      host_path = try(volume.value.host_path, null)

      dynamic "docker_volume_configuration" {
        for_each = try(volume.value.docker_volume_configuration, [])
        content {
          autoprovision = try(docker_volume_configuration.value.autoprovision, false)
          driver        = try(docker_volume_configuration.value.driver, null)
          driver_opts   = try(docker_volume_configuration.value.driver_opts, {})
          labels        = try(docker_volume_configuration.value.labels, {})
          scope         = try(docker_volume_configuration.value.scope, "shared")
        }
      }
      dynamic "efs_volume_configuration" {
        for_each = try(volume.value.efs_volume_configuration, [])
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = try(efs_volume_configuration.value.root_directory, null)
          transit_encryption      = try(efs_volume_configuration.value.transit_encryption, "DISABLED")
          transit_encryption_port = try(efs_volume_configuration.value.transit_encryption_port, null)

          dynamic "authorization_config" {
            for_each = try(efs_volume_configuration.value.authorization_config, [])
            content {
              access_point_id = try(authorization_config.value.access_point_id, null)
              iam             = try(authorization_config.value.iam, null)
            }
          }
        }
      }

      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = try(volume.value.fsx_windows_file_server_volume_configuration, [])
        content {
          file_system_id = fsx_windows_file_server_volume_configuration.value.file_system_id
          root_directory = fsx_windows_file_server_volume_configuration.value.root_directory

          dynamic "authorization_config" {
            for_each = fsx_windows_file_server_volume_configuration.value.authorization_config
            content {
              credentials_parameter = authorization_config.value.credentials_parameter
              domain                = authorization_config.value.domain
            }
          }
        }
      }

    }

  }
  tags = var.tags
}


### ECS Task service ###
resource "aws_ecs_service" "this" {
  name    = var.name
  cluster = var.cluster
  dynamic "alarms" {
    for_each = var.alarms

    content {
      alarm_names = alarms.value.alarm_names
      enable      = try(alarms.value.enable, true)
      rollback    = try(alarms.value.rollback, true)
    }
  }

  dynamic "capacity_provider_strategy" {
    # Set by task set if deployment controller is external
    for_each = var.capacity_provider_strategy

    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }


  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker

    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  dynamic "deployment_controller" {
    for_each = var.deployment_controller

    content {
      type = try(deployment_controller.value.type, "EXTERNAL")
    }
  }

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = local.iam_role_arn #### Check this 
  launch_type                        = local.is_external_deployment || length(var.capacity_provider_strategy) > 0 ? null : var.launch_type

  dynamic "load_balancer" {
    # Set by task set if deployment controller is external
    for_each = { for k, v in var.load_balancer : k => v if !local.is_external_deployment }

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
    }
  }



  dynamic "network_configuration" {
    # Set by task set if deployment controller is external
    for_each = var.network_mode == "awsvpc" && !local.is_external_deployment ? [local.network_configuration] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_groups
      subnets          = network_configuration.value.subnets
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy

    content {
      field = try(ordered_placement_strategy.value.field, null)
      type  = ordered_placement_strategy.value.type
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints

    content {
      expression = try(placement_constraints.value.expression, null)
      type       = placement_constraints.value.type
    }
  }

  # Set by task set if deployment controller is external
  platform_version    = local.is_fargate && !local.is_external_deployment ? var.platform_version : null
  scheduling_strategy = local.is_fargate ? "REPLICA" : var.scheduling_strategy

  dynamic "service_connect_configuration" {
    for_each = length(var.service_connect_configuration) > 0 ? [var.service_connect_configuration] : []

    content {
      enabled = try(service_connect_configuration.value.enabled, true)

      dynamic "log_configuration" {
        for_each = try([service_connect_configuration.value.log_configuration], [])

        content {
          log_driver = try(log_configuration.value.log_driver, null)
          options    = try(log_configuration.value.options, null)

          dynamic "secret_option" {
            for_each = try(log_configuration.value.secret_option, [])

            content {
              name       = secret_option.value.name
              value_from = secret_option.value.value_from
            }
          }
        }
      }

      namespace = lookup(service_connect_configuration.value, "namespace", null)

      dynamic "service" {
        for_each = try([service_connect_configuration.value.service], [])

        content {

          dynamic "client_alias" {
            for_each = try([service.value.client_alias], [])

            content {
              dns_name = try(client_alias.value.dns_name, null)
              port     = client_alias.value.port
            }
          }

          discovery_name        = try(service.value.discovery_name, null)
          ingress_port_override = try(service.value.ingress_port_override, null)
          port_name             = service.value.port_name
        }
      }
    }
  }

  dynamic "service_registries" {
    # Set by task set if deployment controller is external
    for_each = length(var.service_registries) > 0 ? [{ for k, v in var.service_registries : k => v if !local.is_external_deployment }] : []

    content {
      container_name = try(service_registries.value.container_name, null)
      container_port = try(service_registries.value.container_port, null)
      port           = try(service_registries.value.port, null)
      registry_arn   = service_registries.value.registry_arn
    }
  }

  task_definition       = local.task_definition
  triggers              = var.triggers
  wait_for_steady_state = var.wait_for_steady_state

  propagate_tags = var.propagate_tags
  tags           = merge(var.tags, var.service_tags)

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  depends_on = [aws_iam_role_policy_attachment.service]

  lifecycle {
    ignore_changes = [
      desired_count, # Always ignored
    ]
  }
}
