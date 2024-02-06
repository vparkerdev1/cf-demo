# • 1 compute instance running Windows Server 2019 in subnet Public Subnet 1
# • 50 GB storage
# • t3a.medium
# • Hostname should “bastion1”
# • Public EIP associated (not reserved)

# • 1 compute instance running RedHat in subnet WP Subnet 1
# • 20 GB storage
# • t3a.micro
# • Hostname should be “wpserver1”

# • 1 compute instance running RedHat in subnet WP Subnet 2
# • 20 GB storage
# • t3a.micro
# • Hostname should be “wpserver2”

data "aws_ami" "redhat" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }
}

data "aws_ami" "microsoft" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["windows-2019-base*"]
  }
}

module "bastion1" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "bastion1"
  
  instance_type          = "t3a.medium"
  key_name               = "cf-demo"
  monitoring             = true
  vpc_security_group_ids = ["sg-00087434a624b8013"]
  ami = data.aws_ami.microsoft.id
  subnet_id              = "subnet-0ff6355ed6a66e494"
  root_block_device = [ {
    volume_size = 50
  }
  ]
user_data = <<EOT
  <powershell>
  Rename-Computer -NewName bastion1 -Force
  Restart-Computer
  </powershell>
EOT
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "wpserver1" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "wpserver1"

  instance_type          = "t3a.micro"
  key_name               = "cf-demo"
  monitoring             = true
  vpc_security_group_ids = ["sg-004d71fbab51fce4e", "sg-0b541b3feec066b02"]
  ami = data.aws_ami.redhat.id
  subnet_id              = "subnet-06ad12b3cae983377"
  root_block_device = [ {
    volume_size = 20
  }
  ]
  
  user_data = <<-EOT
    #!/bin/bash
    sudo su
    
    #Set Hostname
    hostnamectl set-hostname wpserver1
    
    #install and start apache
    yum update -y
    yum install -y httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    EOT

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "wpserver2" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "wpserver2"

  instance_type          = "t3a.micro"
  key_name               = "cf-demo"
  monitoring             = true
  vpc_security_group_ids = ["sg-004d71fbab51fce4e", "sg-0b541b3feec066b02"]
  ami = data.aws_ami.redhat.id
  subnet_id              = "subnet-04403218cf4f7c413"
  root_block_device = [ {
    volume_size = 20
  }
  ]
  
  user_data = <<-EOT
    #!/bin/bash
    sudo su
    # Set hostname
    hostnamectl set-hostname wpserver2
    
    # install and start apache
    yum update -y
    yum install -y httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    EOT

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_eip" "this" {
  instance = module.bastion1.id
}