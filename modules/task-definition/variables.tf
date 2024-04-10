variable "family" {
  type        = string
  description = "(Required) A unique name for your task definition."
}

variable "container_definitions" {
  type        = any
  description = "(Required) A list of valid container definitions provided as a single valid JSON document. Please note that you should only provide values that are part of the container definition document. For a detailed description of what parameters are available, see the Task Definition Parameters section from the official Developer Guide."
}

variable "cpu" {
  type        = number
  description = "(Optional) Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  default     = null
}

variable "execution_role_arn" {
  type        = string
  description = "(Optional) ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  default     = null
}

variable "inference_accelerator" {
  type = list(object({
    device_name = string
    device_type = string
  }))
  description = <<_EOT
    (Optional) The Elastic Inference accelerator associated with the task. The parameter maps to DeviceName and DeviceType in the Amazon ECS task definition. For more information, see Working with Amazon ECS Elastic Inference Accelerators.
    - device_name - (Required) The Elastic Inference accelerator device name. The deviceName must also be referenced in a container definition as a ResourceRequirement.
    - device_type - (Required) The Elastic Inference accelerator type to use.
    _EOT
  default     = []
}

variable "ipc_mode" {
  type        = string
  description = "(Optional) IPC resource namespace to be used for the containers in the task The valid values are host, task, and none."
  default     = null
}

variable "memory" {
  type        = number
  description = "(Optional) Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  default     = null
}

variable "network_mode" {
  type        = string
  description = "(Optional) Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host."
  default     = null
}

variable "runtime_platform" {
  type = list(object({
    operating_system_family = optional(string)
    cpu_architecture        = optional(string)
  }))
  description = <<_EOT
    (Optional) The operating system family and the architecture of the operating system to use. The valid values are WINDOWS and LINUX. The default operating system is LINUX. The default architecture is x86_64.
    - operating_system_family - (Optional) The operating system family to use. Valid values are WINDOWS or LINUX. The default value is LINUX.
    - cpu_architecture - (Optional) The architecture of the operating system to use. The valid values are x86_64 and arm64. The default value is x86_64.
    _EOT
  default     = []
}

variable "pid_mode" {
  type        = string
  description = "(Optional) Process namespace to use for the containers in the task. The valid values are host and task."
  default     = null
}

variable "placement_constraints" {
  type = list(object({
    expression = optional(string)
    type       = string
  }))
  description = <<_EOT
    (Optional) A set of placement constraints rules that are taken into consideration during task placement. Maximum number of placement_constraints is 10.
    - expression - (Optional) A cluster query language expression to apply to the constraint. For more information, see Cluster Query Language in the Amazon Elastic Container Service Developer Guide.
    - type - (Required) The type of constraint. The valid values are distinctInstance, memberOf, and cardinality.
    _EOT
  default     = []
}

variable "proxy_configuration" {
  type = list(object({
    container_name = string
    properties     = string
    type           = optional(string)
  }))
  description = <<_EOT
    (Optional) The configuration details for the App Mesh proxy.
    - container_name - (Required) The name of the container that will serve as the App Mesh proxy.
    - properties - (Required) The set of network configuration parameters to provide the Container Network Interface (CNI) plugin, specified as key-value pairs.
    - type - (Optional) The proxy type. The default value is APPMESH.
    _EOT
  default     = []
}

variable "ephemeral_storage" {
  type = list(object({
    size_in_gib = number
  }))
  description = <<_EOT
    (Optional) The amount of ephemeral storage to allocate for the task. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on Fargate. For more information, see Amazon ECS task storage.
    - size_in_gib - (Required) The total amount, in GiB, of ephemeral storage to set for the task.
    _EOT
  default     = []
}

variable "requires_compatibilities" {
  type        = list(string)
  description = "(Optional) Set of launch types required by the task. The valid values are EC2 and FARGATE."
  default     = ["FARGATE"]
}

variable "skip_destroy" {
  type        = bool
  description = "(Optional) Whether to retain the old revision when the resource is destroyed or replacement is necessary. Default is false."
  default     = false
}

variable "task_role_arn" {
  type        = string
  description = "(Optional) ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  default     = null
}

variable "track_latest" {
  type        = bool
  description = "(Optional) Whether should track latest task definition or the one created with the resource. Default is false."
  default     = false
}

variable "volume" {
  type = list(object({
    name      = string
    host_path = optional(string)
    docker_volume_configuration = optional(list(object({
      autoprovision = optional(bool)
      driver_opts   = optional(map(string))
      driver        = optional(string)
      labels        = optional(map(string))
      scope         = optional(string)
    })))
    efs_volume_configuration = optional(list(object({
      file_system_id          = string
      root_directory          = optional(string)
      transit_encryption      = optional(string)
      transit_encryption_port = optional(number)
      authorization_config = optional(list(object({
        access_point_id = string
        iam             = string
      })))
    })))
    fsx_windows_file_server_volume_configuration = optional(list(object({
      file_system_id = string
      root_directory = string
      authorization_config = list(object({
        credentials_parameter = string
        domain                = string
      }))
    })))
  }))
  description = <<_EOT
    (Optional) A set of volume blocks that containers in your task may use.
    - name - (Required) The name of the volume. Up to 255 letters (uppercase and lowercase), numbers, hyphens, and underscores are allowed.
    - host_path - (Optional) The path on the host container instance that is presented to the container. If the sourcePath value does not exist on the host container instance, the Docker daemon creates it. If the sourcePath value does exist, the contents of the source path folder are exported.
    - docker_volume_configuration - (Optional) The Docker volume configuration to use for the volume. This parameter maps to Volumes in the Create a container section of the Docker Remote API and the --volume option to docker run.
    - efs_volume_configuration - (Optional) The Amazon Elastic File System (Amazon EFS) volume configuration to use for the volume. This parameter maps to EFSVolumeConfiguration in the Amazon Elastic Container Service API.
    - fsx_windows_file_server_volume_configuration - (Optional) The Amazon FSx for Windows File Server volume configuration to use for the volume. This parameter maps to FSxWindowsFileServerVolumeConfiguration in the Amazon Elastic Container Service API.
    _EOT
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Key-value map of resource tags. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = {}
}

### ECS Service ####

variable "cluster" {
  type        = string
  description = "(Required) The name of the ECS cluster."
}

variable "alarms" {
  type = list(object({
    alarm_names = string
    enable      = string
    rollback    = string
  }))
  description = <<_EOT
    (Optional) A list of CloudWatch Alarms to monitor the service. The service will be created with the CloudWatch Alarms attached. The format is a list of maps, where each map should contain the following keys:
    - alarm_names - (Required) The list of CloudWatch Alarm names to attach to the service.
    - enable - (Required) Enable the alarm. Default is true.
    - rollback - (Required) Rollback the service if the alarm is triggered. Default is false.
    _EOT
  default     = []
}

variable "capacity_provider_strategy" {
  type = list(object({
    base              = optional(string)
    capacity_provider = string
    weight            = optional(string)
  }))
  description = <<_EOT
    (Optional) The capacity provider strategy to use for the service. A capacity provider strategy consists of one or more capacity providers along with the base and weight to assign to them. A capacity provider must be associated with the cluster to be used in a capacity provider strategy. The PutClusterCapacityProviders API is used to update the list of available capacity providers for a cluster. Only capacity providers with an ACTIVE or UPDATING status can be used. If specifying a capacity provider that uses an Auto Scaling group, the capacity provider must already be created. New capacity providers can be created with the CreateCapacityProvider API operation. You can specify up to 10 capacity providers in one capacity provider strategy. Services can use multiple capacity providers in a strategy. You can specify up to 10 capacity providers in one capacity provider strategy.
    - base - (Optional) The base value designates how many tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined. If no value is specified, the default value is 0.
    - capacity_provider - (Required) The short name of the capacity provider.
    - weight - (Optional) The weight value designates the relative percentage of the total number of launched tasks that should use the specified capacity provider. The weight value is taken into consideration after the base value, if defined, is satisfied.
    _EOT
  default     = []
}

variable "deployment_circuit_breaker" {
  type = list(object({
    enable   = string
    rollback = string
  }))
  description = <<_EOT
    (Optional) The deployment circuit breaker can be used to define a strategy to avoid deployment failures when a service is unable to reach a steady state. The deployment circuit breaker allows you to configure deployment maximum percent and minimum healthy percent. The deployment circuit breaker is only available to services using the rolling update (ECS) deployment type. The format is a list of maps, where each map should contain the following keys:
    - enable - (Required) Whether to enable the deployment circuit breaker. Default is false.
    - rollback - (Required) Whether to enable the rollback of the service if the deployment fails. Default is false.
    _EOT
  default     = []
}

variable "deployment_controller" {
  type = list(object({
    type = optional(string)
  }))
  description = <<_EOT
    (Optional) The deployment controller to use for the service. The deployment controller is used to determine the deployment strategy to use during a service deployment. The default value is ECS. The format is a list of maps, where each map should contain the following keys:
    - type - (Optional) The deployment controller type to use. Valid values are ECS and CODE_DEPLOY. Default is ECS.
    _EOT
  default     = []
}

variable "deployment_maximum_percent" {
  type        = string
  description = "(Optional) Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Not valid when using the DAEMON scheduling strategy."
  default     = null
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "(Optional) Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
  default     = null
}

variable "desired_count" {
  type        = number
  description = "(Optional) Number of instances of the task definition to place and keep running. Defaults to 0. Do not specify if using the DAEMON scheduling strategy."
  default     = null
}

variable "enable_ecs_managed_tags" {
  type        = bool
  description = " (Optional) Specifies whether to enable Amazon ECS managed tags for the tasks within the service."
  default     = true
}

variable "enable_execute_command" {
  type        = bool
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  default     = false
}

variable "force_new_deployment" {
  type        = bool
  description = "(Optional) Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g., myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered_placement_strategy and placement_constraints updates."
  default     = true
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "(Optional) Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers."
  default     = null
}

variable "launch_type" {
  type        = string
  description = "(Optional) Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. Conflicts with capacity_provider_strategy"
  default     = "FARGATE"
}

