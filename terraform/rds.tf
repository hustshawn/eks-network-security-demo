locals {
  pg_db_name     = "SecurityGroupForPodsDemo"
  pg_db_username = "sgp_demo"
  pg_db_password = "asdf1234"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier                     = "${local.name}-db"
  instance_use_identifier_prefix = true

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t4g.large"

  allocated_storage = 20

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = local.pg_db_name
  username = local.pg_db_username

  manage_master_user_password = false                # For production, please enable this option to use secret manager to store DB credentials
  password                    = local.pg_db_password # for demo purpose only

  port = 5432

  create_db_subnet_group = true
  # subnet_ids             = data.aws_subnets.selected.ids
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  auto_minor_version_upgrade = false
  enabled_cloudwatch_logs_exports = [
    "postgresql",
  ]

  tags = local.tags
}
