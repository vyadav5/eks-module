variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "region"
  type        = string
}

variable "enabled_cluster_log_types" {
  description = "List of enabled log types for EKS cluster"
  type        = list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "subnet_ids" {
  description = "A list of subnets for worker nodes"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for EKS cluster"
  type        = list(string)
  default     = []
}

variable "private_endpoint" {
  description = "Enable private endpoint access for EKS API"
  type        = bool
  default     = false
}

variable "public_endpoint" {
  description = "Enable public endpoint access for EKS API"
  type        = bool
  default     = true
}

variable "cluster_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_kms" {
  description = "Enable KMS encryption for EKS secrets"
  type        = bool
  default     = false
}

variable "authentication_mode" {
  description = "EKS cluster authentication mode"
  type        = string
  default     = "API"  # IAM-based authentication
}

#KMS
variable "deletion_window" {
  description = "Number of days before deleting the KMS key"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable KMS key rotation"
  type        = bool
  default     = true
}


#IAM
variable "iam_name" {
  description = "Name of the IAM role for EKS cluster"
  type        = string
}

variable "iam_tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}

variable "config_output_path" {
  description = "kubeconfig output path"
  type        = string
}

variable "node_group_role_arn" {
  description = "IAM Role ARN for EKS Node Group"
  type        = string
}





variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an admin via access entry"
  type        = bool
  default     = false
}


