output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public-subnet[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private-subnet[*].id
}

output "security_group_id" {
  description = "ID of the EKS node group security group"
  value       = aws_security_group.node_group_sg.id
}

output "vpc_id"{
  description = "ID of the EKS node group security group"
  value       = aws_vpc.k8svpc.id
}

# output "eks_kms_key_arn" {
#   value       = module.eks.kms_key_arn
#   description = "The ARN of the KMS key from EKS module"
# }
