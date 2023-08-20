variable "scaling_config_desired_size" {
  type = number
}

variable "scaling_config_max_size" {
  type = number
}

variable "cluster_version" {
  type = string
}

variable "scaling_config_min_size" {
  type = number
}

variable "max_unavailable_nodes" {
  type = number
}

variable "ami-type" {
  type = string
}

variable "capacity-type" {
  type = string
}

variable "disk-size" {
  type = number
}

variable "instance-type" {
  type = string
}

variable "project" {
  description = "Name of the project deployment."
  type        = string
}

variable "logs_retention_days" {
  type = number
}

variable "enable_controlplane_logging" {
  type = bool
}

variable "cluster_allowed_cidr_blocks" {
  description = "CIDR blocks used to access to the EKS public API"
  type        = list(any)
}

variable "private_subnet_id" {}

variable "public_subnet_id" {}

variable "eks_cluster_sg" {}

variable "eks_nodes_sg" {}

variable "node_iam_policies" {
  description = "List of IAM policies to attach to EKS nodes"
  type        = map(any)
}

variable "cluster_iam_policies" {
  description = "List of IAM policies to attach to EKS cluster"
  type        = map(any)
}

variable "cluster_endpoint_private_access" {
  type = bool
}

variable "cluster_endpoint_public_access" {
  type = bool
}

variable "env" {
  type = string
}