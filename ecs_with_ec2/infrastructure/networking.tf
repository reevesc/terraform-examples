#
# VPC Configuration
#
data "aws_availability_zones" "available" { 
  state = "available"
}

locals {
  availability_zone_names = data.aws_availability_zones.available.names
}

resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.app_name}-${var.environment_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = var.availability_zone_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.availability_zone_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 10 + count.index)
  map_public_ip_on_launch = true
  tags                    = {
    Name = "${var.app_name}-${var.environment_name}-${local.availability_zone_names[count.index]}"
  }
}


#
# Internet Gateway
#
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags   = {
    Name = "${var.app_name}-${var.environment_name}-igw"
  }
}

resource "aws_eip" "main" {
  count      = var.availability_zone_count
  depends_on = [aws_internet_gateway.main]
  tags       = {
    Name = "${var.app_name}-${var.environment_name}-eip-${local.availability_zone_names[count.index]}"
  }
}


#
# Public Route Table
#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = {
    Name = "${var.app_name}-${var.environment_name}-rt-public"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.availability_zone_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
