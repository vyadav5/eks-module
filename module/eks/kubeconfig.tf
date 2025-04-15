resource "local_file" "kubeconfig" {
  content              = local.kubeconfig
  filename             = pathexpand("~/.kube/config")
  file_permission      = "0644"
  directory_permission = "0755"
  depends_on           = [aws_eks_cluster.eks_cluster]
}