
provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = "rds-db-subnet-group"
  subnet_ids = slice(data.aws_subnets.default_subnets.ids, 0, 2)

  tags = {
    Name = "rds-db-subnet-group"
  }
}

resource "aws_security_group" "rds_mysql_sg" {
  vpc_id      = data.aws_vpc.default.id
  name        = "rds-mysql-sg"
  description = "Grupo de seguranca para RDS MySQL"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "product" {
  identifier             = "mysql-ftc4-product"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  db_name                = "product"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_db_subnet_group.name
}

resource "aws_db_instance" "order_db" {
  identifier             = "mysql-ftc4-order"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  db_name                = "order_db"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_db_subnet_group.name
}
resource "aws_db_instance" "payment" {
  identifier             = "mysql-ftc4-payment"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  db_name                = "payment"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_db_subnet_group.name
}
locals {
  mongodb_atlas_api_pub_key            = "hytgjosm"
  mongodb_atlas_api_pri_key            = "f05ca9ce-c7ec-424c-8e27-7969d2398c7d"
  mongodb_atlas_org_id                 = "674e512d16f28410c4db7124"
  mongodb_atlas_database_username      = "root"
  mongodb_atlas_database_user_password = "root"
  mongodb_atlas_accesslistip           = "0.0.0.0"
}
terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
}

provider "mongodbatlas" {
  public_key  = local.mongodb_atlas_api_pub_key
  private_key = local.mongodb_atlas_api_pri_key
}
resource "mongodbatlas_project" "my_project" {
  name   = "cliente-project"
  org_id = local.mongodb_atlas_org_id
}
resource "mongodbatlas_cluster" "my_cluster" {
  project_id                   = mongodbatlas_project.my_project.id
  name                         = "cliente-cluster"
  provider_name                = "TENANT"
  backing_provider_name        = "AWS"
  provider_region_name         = "US_EAST_1"
  provider_instance_size_name  = "M0"
  mongo_db_major_version       = "4.4"
  auto_scaling_disk_gb_enabled = "false"
}

resource "mongodbatlas_database_user" "my_user" {
  username           = local.mongodb_atlas_database_username
  password           = local.mongodb_atlas_database_user_password
  project_id         = mongodbatlas_project.my_project.id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}

resource "mongodbatlas_project_ip_access_list" "my_ipaddress" {
  project_id = mongodbatlas_project.my_project.id
  ip_address = local.mongodb_atlas_accesslistip
  comment    = "My IP Address"
}
