module "eks_pods_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-eks-pods-sg"
  description = "EKS Pod security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "EKS Pod inbound"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "EKS Pod outbound-everywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = merge(local.tags,
    {
      Name = "${local.name}-eks-pods-sg"
  })
}


module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-rds-sg"
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from EKS pod security group"
      source_security_group_id = module.eks_pods_security_group.security_group_id
    }
  ]

  tags = merge(local.tags,
    {
      Name = "${local.name}-rds-sg"
  })
}
