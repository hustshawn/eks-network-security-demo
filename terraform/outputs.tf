output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.db.db_instance_address
}

output "db_default_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = module.db.db_instance_master_user_secret_arn
}

output "rds_security_group" {
  value = module.rds_security_group.security_group_id
}

output "eks_pods_security_group" {
  value = module.eks_pods_security_group.security_group_id
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}
