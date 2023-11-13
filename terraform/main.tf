provider "aws" {
  profile = "default"
  region  = local.region
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}


data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}


locals {
  name            = "eks-network-security-demo"
  region          = "ap-southeast-1"
  cluster_version = "1.27"
  vpc_cidr        = "10.1.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Name = local.name
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = local.name
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.2xlarge"]
      min_size       = 2
      max_size       = 5
      desired_size   = 3
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }

      # Must enable network policy and security-group-for-pods support
      # https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html
      configuration_values = jsonencode({
        enableNetworkPolicy = "true",
        env = {
          ENABLE_POD_ENI = "true"
          # Set to "standard" mode to make both network policies and security-group-for-pods work together
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
      })
    }
  }

  tags = local.tags
}

resource "kubernetes_namespace_v1" "sgp_demo_ns" {
  metadata {
    name = "sgp-demo"
  }
}
resource "kubernetes_namespace_v1" "another-ns" {
  metadata {
    name = "another-ns"
  }
}

################################################################################
# Supporting Resources
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
