module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "alb_sg"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp","https-443-tcp"]
  egress_rules        = ["all-all"]
  
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "rds_sg"
  description = "Security group for PostgreSQL (port 5432) RDS connection to wp instances"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["10.1.2.0/24", "10.1.3.0/24"]
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]

}

module "ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "ssh_sg"
  description = "Security group for ssh (port 22) access to EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["10.1.0.0/24", "10.1.1.0/24"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]

}

module "rdp_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "rdp_sg"
  description = "Security group allowing rdp (port 3389) to bastion1"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["76.98.214.133/32"]
  ingress_rules       = ["rdp-tcp"]
  egress_rules        = ["all-all"]

}

module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"
  depends_on = [ module.alb_sg ]

  name        = "web_server_sg"
  description = "Security group for https (port 443) and http (port 80) to ec2 from alb"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "https-443-tcp"]
  egress_rules        = ["all-all"]

}