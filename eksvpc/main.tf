//provider
provider "aws" {
  region = "us-east-1"

}
// VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC for ${var.service}-${var.stage}"
  }
}

# Public Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet gateway for ${var.service}-${var.stage}"
  }
}

# Public subnets
resource "aws_subnet" "subnet_public_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet - Public - for ${var.service}-${var.stage}"
    CIDR = "10.0.0.0/20"
    AZ   = "us-east-1a"
  }
}

resource "aws_subnet" "subnet_public_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet - Public - for ${var.service}-${var.stage}"
    CIDR = "10.0.16.0/20"
    AZ   = "us-east-1b"
  }
}

resource "aws_network_acl" "network_acl_public" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.subnet_public_1.id,
    aws_subnet.subnet_public_2.id
  ]

  tags = {
    Name = "Network ACL - Public - for ${var.service}-${var.stage}"
  }
}

resource "aws_network_acl_rule" "network_acl_rule_inbound_public" {
  network_acl_id = aws_network_acl.network_acl_public.id
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "network_acl_rule_outbound_public" {
  network_acl_id = aws_network_acl.network_acl_public.id
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    ignore_changes = [
      propagating_vgws
    ]
  }

  tags = {
    Name = "Route table - Public - for ${var.service}-${var.stage}"
  }
}

resource "aws_route" "route_for_public" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "route_table_association_for_subnet_public_1_and_route_table_public" {
  subnet_id      = aws_subnet.subnet_public_1.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "route_table_association_for_subnet_public_2_and_route_table_public" {
  subnet_id      = aws_subnet.subnet_public_2.id
  route_table_id = aws_route_table.route_table_public.id
}

# Private subnets
resource "aws_subnet" "subnet_private_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.96.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet - Private - for ${var.service}-${var.stage}"
    CIDR = "10.0.96.0/20"
    AZ   = "us-east-1a"
  }
}

resource "aws_subnet" "subnet_private_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.112.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet - Private - for ${var.service}-${var.stage}"
    CIDR = "10.0.112.0/20"
    AZ   = "us-east-1b"
  }
}

resource "aws_network_acl" "network_acl_private" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.subnet_private_1.id,
    aws_subnet.subnet_private_2.id
  ]

  tags = {
    Name = "Network ACL - Private - for ${var.service}-${var.stage}"
  }
}

resource "aws_network_acl_rule" "network_acl_rule_inbound_private" {
  network_acl_id = aws_network_acl.network_acl_private.id
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "network_acl_rule_outbound_private" {
  network_acl_id = aws_network_acl.network_acl_private.id
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    ignore_changes = [
      propagating_vgws
    ]
  }

  tags = {
    Name = "Route table - Private - for ${var.service}-${var.stage}"
  }
}

resource "aws_route_table_association" "route_table_association_for_subnet_private_1_and_route_table_private" {
  subnet_id      = aws_subnet.subnet_private_1.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route_table_association" "route_table_association_for_subnet_private_2_and_route_table_private" {
  subnet_id      = aws_subnet.subnet_private_2.id
  route_table_id = aws_route_table.route_table_private.id
}

# Security Group
resource "aws_security_group" "security_group_ec2" {
  name        = "EC2"
  description = "Security group - EC2 - ${var.service}-${var.stage}"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group" "security_group_alb" {
  name        = "Application Load Balancer"
  description = "Security group - Application Load Balancer - ${var.service}-${var.stage}"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "security_group_rds" {
  name        = "RDS"
  description = "Security group - RDS - ${var.service}-${var.stage}"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "172.16.0.0/12"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
