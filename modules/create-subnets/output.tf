output "id" {
  description = "AWS Subnet Id"
  value       = {
    for k, v in aws_subnet.cluster_subnets: k => v.id
  }
}
