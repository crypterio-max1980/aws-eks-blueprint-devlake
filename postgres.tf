# ----------------------------------------
# RDS PostgreSQL Security Group
# ----------------------------------------

resource "aws_security_group" "rds_sg" {
  name        = "postgres-metabase-rds-sg"
  description = "Allow PostgreSQL access from EKS and VPC"
  vpc_id      = aws_vpc.main.id

  # Allow PostgreSQL from authorized EKS workloads
  ingress {
    description     = "PostgreSQL from EKS workloads"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_rds_client.id]
  }

  # Allow PostgreSQL from the VPC CIDR
  ingress {
    description = "PostgreSQL from VPC CIDR"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow outbound traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "postgres-metabase-rds-sg"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# ----------------------------------------
# EKS-to-RDS Client Security Group
# ----------------------------------------

resource "aws_security_group" "eks_rds_client" {
  name        = "eks-rds-client-sg"
  description = "Security group for EKS workloads accessing RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "eks-rds-client-sg"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# ----------------------------------------
# RDS DB Subnet Group
# Use private subnets in at least two AZs
# ----------------------------------------

resource "aws_db_subnet_group" "rds_subnets" {
  name        = "postgres-metabase-private-subnets"
  description = "Private subnets for PostgreSQL RDS"

  subnet_ids = [
    for subnet in aws_subnet.private : subnet.id
  ]

  tags = {
    Name        = "postgres-metabase-private-subnets"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "postgres-metabase"

  # Engine configuration
  engine         = "postgres"
  engine_version = "17.6"
  instance_class = "db.t4g.micro"

  # Storage
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  db_name  = "metabase"
  username = "postgres"
  port     = 5432

  # AWS-managed master password
  manage_master_user_password = true

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false

  # Single-AZ deployment
  multi_az = false

  # Automated backups
  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  # Maintenance
  maintenance_window         = "sun:04:00-sun:05:00"
  auto_minor_version_upgrade = true

  # Security and lifecycle
  deletion_protection = false
  skip_final_snapshot = false

  final_snapshot_identifier = "postgres-metabase-final"

  # CloudWatch log exports
  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  tags = {
    Name        = "postgres-metabase"
    Environment = "production"
    ManagedBy   = "Terraform"
  }

  # Ensure NAT Gateway is created first
  depends_on = [
    aws_nat_gateway.nat
  ]
}

# ----------------------------------------
# Output: Secrets Manager Secret ARN
# ----------------------------------------

output "postgres_master_secret_arn" {
  description = "Secrets Manager ARN for the PostgreSQL master password"
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}
