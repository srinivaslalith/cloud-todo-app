# NOTE: This is a minimal, opinionated skeleton. Review before real usage.

data "aws_caller_identity" "current" {}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.project}-vpc" }
}

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-public-${replace(each.value, "/", "-")}" }
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = false
  tags = { Name = "${var.project}-private-${replace(each.value, "/", "-")}" }
}

# IGW + routes (omitted: NAT for brevity)

# RDS PostgreSQL (public for demo; secure it for prod)
resource "aws_db_subnet_group" "db" {
  name       = "${var.project}-db-subnet"
  subnet_ids = [for s in aws_subnet.private : s.id]
}

resource "aws_security_group" "db" {
  name        = "${var.project}-db-sg"
  description = "DB access"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: lock this down!
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project}-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = true # For demo; set false + private access for prod
  skip_final_snapshot    = true
}

output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

# EKS cluster using a popular community module is recommended; omitted for brevity.
# Optionally add: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws
