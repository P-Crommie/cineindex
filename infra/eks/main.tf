module "ekscluster" {
  source                          = "./modules/eks"
  project                         = var.project
  env                             = var.env
  scaling_config_desired_size     = var.scaling_config_desired_size
  scaling_config_max_size         = var.scaling_config_max_size
  scaling_config_min_size         = var.scaling_config_min_size
  max_unavailable_nodes           = var.max_unavailable_nodes
  cluster_version                 = var.cluster_version
  ami-type                        = var.ami-type
  capacity-type                   = var.capacity-type
  disk-size                       = var.disk-size
  cluster_allowed_cidr_blocks     = var.cluster_allowed_cidr_blocks
  instance-type                   = var.instance-type
  logs_retention_days             = var.logs_retention_days
  eks_cluster_sg                  = module.network.eks_cluster_sg
  eks_nodes_sg                    = module.network.eks_nodes_sg
  private_subnet_id               = module.network.private_subnet_id
  public_subnet_id                = module.network.public_subnet_id
  enable_controlplane_logging     = var.enable_controlplane_logging
  node_iam_policies               = var.node_iam_policies
  cluster_iam_policies            = var.cluster_iam_policies
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
}

module "network" {
  source             = "./modules/network"
  project            = var.project
  env                = var.env
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  subnet_cidr_bits   = var.subnet_cidr_bits
}

data "aws_eks_cluster" "cluster" {
  name = module.ekscluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.ekscluster.cluster_id
}

data "aws_eks_node_group" "node_name" {
  node_group_name = module.ekscluster.node_group_name
  cluster_name    = module.ekscluster.cluster_id

  depends_on = [data.aws_eks_cluster.cluster]
}

resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.project_region} update-kubeconfig --name ${data.aws_eks_cluster.cluster.name}"
  }

  depends_on = [data.aws_eks_cluster.cluster]
}

resource "helm_release" "argo-cd" {
  name             = "argocd"
  replace          = true
  create_namespace = true
  cleanup_on_fail  = true
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argo_helm_version
  values = [
    file("${path.module}/config/argocd-values.yml")
  ]

  depends_on = [data.aws_eks_node_group.node_name]
}
