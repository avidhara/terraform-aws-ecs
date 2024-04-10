output "arn" {
  description = "ARN that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].arn, "")
}

output "id" {
  description = "ARN that identifies the cluster"
  value       = try(aws_ecs_cluster.this[0].id, "")
}
