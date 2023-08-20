# Creating the Worker Node
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.env}-${var.project}-NodeGroup"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_id

  scaling_config {
    desired_size = var.scaling_config_desired_size
    max_size     = var.scaling_config_max_size
    min_size     = var.scaling_config_min_size
  }

  update_config {
    max_unavailable = var.max_unavailable_nodes
  }

  ami_type       = var.ami-type
  capacity_type  = var.capacity-type
  disk_size      = var.disk-size
  instance_types = [var.instance-type]

  depends_on = [aws_iam_role_policy_attachment.nodePolicy]
}