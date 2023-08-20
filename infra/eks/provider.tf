terraform {
  required_version = ">= 1.5.2"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.6"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.project_region
  default_tags {
    tags = merge(
      var.tags,
      {
        workspace = "${terraform.workspace}"
        project   = "${var.project}"
        env       = "${var.env}"
      },
    )
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(module.ekscluster.kubeconfig-certificate-authority-data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}
