output "private_subnet_id" {
  value = aws_subnet.private[*].id
}

output "public_subnet_id" {
  value = aws_subnet.public[*].id
}

output "eks_cluster_sg" {
  value = aws_security_group.eks_cluster.id
}

output "eks_nodes_sg" {
  value = aws_security_group.eks_nodes.id
}