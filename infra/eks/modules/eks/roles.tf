resource "aws_iam_role" "cluster_role" {
  name = "${var.env}-${var.project}-ClusterRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "node_role" {
  name = "${var.env}-${var.project}-NodeRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${var.env}-${var.project}-EbsCSIDriverRole"

  assume_role_policy = data.aws_iam_policy_document.eksdoc_assume_role_policy.json
  depends_on         = [aws_iam_openid_connect_provider.eksopidc]
}

resource "aws_iam_role_policy_attachment" "clusterPolicy" {
  for_each = var.cluster_iam_policies

  policy_arn = each.value
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "nodePolicy" {
  for_each   = var.node_iam_policies

  policy_arn = each.value
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver_role.name
  depends_on = [aws_iam_role.ebs_csi_driver_role]
}