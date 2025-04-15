output "eks_kms_key_arn" {
  description = "The ARN of the KMS key used for encryption (if enabled)"
  value       = var.enable_kms ? aws_kms_key.eks_kms[0].arn : null
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

# output "kms_key_arn"{
#   description = "kms key arn"
#   value = aws_kms_key.eks_kms[0].arn

# # }
output "api_version" {
  value = local.k8s_api_version
}

