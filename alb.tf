# 1 ALB that has listeners in subnets Public Subnet 1 & 2
# • listens on port 443/TCP
# ▪ forwards traffic to the instance in subnet WP Subnet 1

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "my-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = ["subnet-0afdda50818fdd5b0", "subnet-0ff6355ed6a66e494"]
  security_groups = [module.alb_sg.security_group_id]

    access_logs = {
    bucket = module.log_bucket.s3_bucket_id
    prefix = "access-logs"
  }

  connection_logs = {
    bucket  = module.log_bucket.s3_bucket_id
    enabled = true
    prefix  = "connection-logs"
  }
    # Route53 Record(s)
  route53_records = {
    A = {
      name    = "cfwebapp"
      type    = "A"
      zone_id = aws_route53_zone.primary.id
    }
    AAAA = {
      name    = "cfwebapp"
      type    = "AAAA"
      zone_id = aws_route53_zone.primary.id
    }
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:us-west-1:116796050512:certificate/c29bd5d6-1dce-41ad-8ccf-43b3cfb34c39"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix      = "web"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}

resource "aws_route53_zone" "primary" {
  name = "cfdemotest.com"
}
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = module.alb.target_groups.ex-instance.arn
  target_id        = module.wpserver1.id
  port             = 80
}

locals {
  name = "cfwebapp"
}