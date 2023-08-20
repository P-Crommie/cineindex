resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  count             = var.enable_controlplane_logging ? 1 : 0
  name              = "/aws/eks/${var.env}-${var.project}-cluster/cluster"
  retention_in_days = var.logs_retention_days
}