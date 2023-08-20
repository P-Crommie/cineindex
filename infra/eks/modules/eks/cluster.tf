# EKS CLuster Definition
resource "aws_eks_cluster" "this" {
  name     = "${var.env}-${var.project}-cluster"
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids      = [var.eks_cluster_sg, var.eks_nodes_sg]
    subnet_ids              = flatten([var.public_subnet_id, var.private_subnet_id])
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_allowed_cidr_blocks
  }

  depends_on = [
    aws_iam_role_policy_attachment.clusterPolicy,
    aws_cloudwatch_log_group.eks_cluster_logs,
  ]

  enabled_cluster_log_types = var.enable_controlplane_logging ? ["audit", "api", "authenticator", "scheduler", "controllerManager"] : []

}