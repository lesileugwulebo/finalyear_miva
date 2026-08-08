resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-aws-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.10.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-a"
    Tier = "Public"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.11.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-b"
    Tier = "Public"
  }
}

resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.20.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-web-a"
    Tier = "Web"
  }
}

resource "aws_subnet" "web_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.21.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.name_prefix}-web-b"
    Tier = "Web"
  }
}

resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.30.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-app-a"
    Tier = "Application"
  }
}

resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.31.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.name_prefix}-app-b"
    Tier = "Application"
  }
}

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.40.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-db-a"
    Tier = "Database"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.41.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.name_prefix}-db-b"
    Tier = "Database"
  }
}

resource "aws_subnet" "management" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.50.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-management"
    Tier = "Management"
  }
}

resource "aws_subnet" "transit_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.60.0/28"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-transit-a"
    Tier = "Transit"
  }
}

resource "aws_subnet" "transit_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.60.16/28"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.name_prefix}-transit-b"
    Tier = "Transit"
  }
}

# Elastic IP & NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-web-rt"
  }
}

resource "aws_route_table_association" "web_a" {
  subnet_id      = aws_subnet.web_a.id
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table_association" "web_b" {
  subnet_id      = aws_subnet.web_b.id
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table" "application" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-application-rt"
  }
}

resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.application.id
}

resource "aws_route_table_association" "app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.application.id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-database-rt"
  }
}

resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.database.id
}

resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.database.id
}

resource "aws_route_table" "management" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-management-rt"
  }
}

resource "aws_route_table_association" "management" {
  subnet_id      = aws_subnet.management.id
  route_table_id = aws_route_table.management.id
}

# Security Groups
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow public HTTP/HTTPS entry to Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from Internet"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP redirect testing"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Web proxy tier security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description     = "App tier traffic"
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.application.id]
  }

  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
}

resource "aws_security_group" "application" {
  name        = "${var.name_prefix}-app-sg"
  description = "Application tier security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App traffic from Web tier"
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    description = "Approved HTTPS response/test traffic from Azure VNet"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.azure_vnet_cidr]
  }

  egress {
    description     = "PostgreSQL to Database tier"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.database.id]
  }

  egress {
    description = "HTTPS to Azure supporting service"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.azure_vnet_cidr]
  }

  egress {
    description = "HTTPS outbound updates"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-app-sg"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-database-sg"
  description = "Database tier security group - isolated"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from App tier only"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.application.id]
  }

  egress {
    description = "Return established VPC traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.name_prefix}-database-sg"
  }
}

resource "aws_security_group" "management" {
  name        = "${var.name_prefix}-management-sg"
  description = "Restricted management security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Approved administrator SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.administrator_cidr]
  }

  egress {
    description = "SSH to internal VPC workloads"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "iPerf3 testing to Azure"
    protocol    = "tcp"
    from_port   = 5201
    to_port     = 5201
    cidr_blocks = [var.azure_vnet_cidr]
  }

  tags = {
    Name = "${var.name_prefix}-management-sg"
  }
}
