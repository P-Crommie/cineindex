# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.env}-${var.project}-cluster-SG"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow worker nodes to communicate with the cluster API Server"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  egress {
    description = "Allow cluster API Server to communicate with the worker nodes"
    from_port   = 1024
    protocol    = "tcp"
    to_port     = 65535
  }
  tags = {
    Name = "${var.env}-${var.project}-cluster-SG"
  }
}

# EKS Node Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "${var.env}-${var.project}-node-SG"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    protocol    = "-1"
    to_port     = 65535
  }

  ingress {
    description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port   = 1025
    protocol    = "tcp"
    to_port     = 65535
  }

  tags = {
    Name = "${var.env}-${var.project}-node-SG"
  }
}