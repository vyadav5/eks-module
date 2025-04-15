resource "aws_iam_role" "eks_cluster_role" {
  name = var.iam_name
  tags = var.iam_tags

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# eks policy attachment

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}


resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_kms_key" "eks_kms" {
  count                    = var.enable_kms ? 1 : 0  
  description              = "KMS key for EKS secrets encryption"
  deletion_window_in_days  = var.deletion_window
  enable_key_rotation      = var.enable_key_rotation
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = var.enabled_cluster_log_types

  access_config {
    authentication_mode = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = false #for this creating manual access entries
  }

  tags = merge(var.cluster_tags, { Name = var.cluster_name })

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_private_access = var.private_endpoint
    endpoint_public_access  = var.public_endpoint
  }

  dynamic "encryption_config" {
    for_each = var.enable_kms ? [1] : []  

    content {
      resources = ["secrets"]
      provider {
        key_arn = aws_kms_key.eks_kms[0].arn
      }
    }
  }

  depends_on = [
    
        aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
        aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
  ]

}

resource "aws_eks_access_entry" "this" {
  for_each = { for k, v in local.merged_access_entries : k => v}

  cluster_name      = aws_eks_cluster.eks_cluster.id
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  principal_arn     = each.value.principal_arn
  type              = try(each.value.type, "STANDARD")
  user_name         = try(each.value.user_name, null)

}

resource "aws_eks_access_policy_association" "this" {
  for_each = { for k, v in local.flattened_access_entries : "${v.entry_key}_${v.pol_key}" => v}

  access_scope {
    namespaces = try(each.value.association_access_scope_namespaces, [])
    type       = each.value.association_access_scope_type
  }

  cluster_name = aws_eks_cluster.eks_cluster.id

  policy_arn    = each.value.association_policy_arn
  principal_arn = each.value.principal_arn

  depends_on = [
    aws_eks_access_entry.this,
  ]
}
