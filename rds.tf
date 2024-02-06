# 1 RDS PostgreSQL Databases running PostgreSQL 11 in subnet DB Subnet 2
# • db.t3.micro
# • DB Name should be “RDS1”

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  engine            = "postgres"
  engine_version    = "14"
  family            = "postgres14"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "RDS1"
  username = "posgres"
  port     = "5432"

  iam_database_authentication_enabled = false

  vpc_security_group_ids = ["sg-0df165e8a545e9740"]
  db_subnet_group_name = "rds-sg"

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  
  monitoring_interval    = "30"
  monitoring_role_name   = "RDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = ["subnet-07124ac8460e81bc9", "subnet-07b92117205eda2c2"]
}