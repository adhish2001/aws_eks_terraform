provider "aws" {
  region = local.region
}

locals {
  name            = "poc-eks"
  cluster_version = "1.29"
  region          = "us-east-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-east-2a", "us-east-2b"]

    vpc_id = "vpc-06e0846e0585d62ff"
    public_subnets = ["10.123.1.0/24", "10.123.2.0/24"]
    private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
    intra_subnets = ["10.123.5.0/24", "10.123.6.0/24"]

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnets
  control_plane_subnet_ids = local.intra_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "testing"
      }
    }
  }

  tags = local.tags
}