variable "eks_node_group_name" {
  description = "Node group name for EKS"
  default     = "eks-node-group"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}