# 5 subnets (spread across two availability zones for high availability)
# • Public Subnet 1 – 10.1.0.0/24 (should be accessible from internet)
# • Public Subnet 2 – 10.1.1.0/24 (should be accessible from internet)
# • WP (Web Application) Subnet 1 – 10.1.2.0/24 (should NOT be accessible from internet)
# • WP (Web Application) Subnet 2 – 10.1.3.0/24 (should NOT be accessible from internet)
# • DB Subnet 1 – 10.1.4.0/24 (should NOT be accessible from internet)
# • DB Subnet 2 – 10.1.5.0/24 (should NOT be accessible from internet)

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "coalfire-demo"
  cidr = "10.1.0.0/16"

  azs             = ["us-west-1b", "us-west-1c"]
  private_subnets = [ "10.1.2.0/24", "10.1.3.0/24"]  
  public_subnets  = ["10.1.0.0/24", "10.1.1.0/24"]
  database_subnets = ["10.1.4.0/24", "10.1.5.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
}
