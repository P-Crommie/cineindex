output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}
output "cluster_id" {
  value = aws_eks_cluster.this.id
}
output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "nodegroup_id" {
  value = aws_eks_node_group.this.id
}

output "node_group_name" {
  value = aws_eks_node_group.this.node_group_name
}