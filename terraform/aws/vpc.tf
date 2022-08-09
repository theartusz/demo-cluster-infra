resource "aws_vpc" "eks_example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.aws.prefix_name}-vpc"
  }
}

resource "aws_internet_gateway" "int_gateway" {
  vpc_id = aws_vpc.eks_example.id

  tags = {
    "Name" = "${var.aws.prefix_name}-igw"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.eks_example.id
  service_name      = "com.amazonaws.eu-north-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    "Name" = "${var.aws.prefix_name}-s3-ep"
  }
}

# I am not sure if 2 subnets are needed or 1 would be just enough
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.eks_example.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1a"

  tags = {
    "Name"                           = "${var.aws.prefix_name}-public1"
    "kubernetes.io/cluster/example}" = "shared"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.eks_example.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1b"

  tags = {
    "Name"                           = "${var.aws.prefix_name}-public2"
    "kubernetes.io/cluster/example}" = "shared"
  }
}


resource "aws_route_table" "eks_rt" {
  vpc_id = aws_vpc.eks_example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.int_gateway.id
  }

  tags = {
    "Name" = "example-rt"
  }
}

resource "aws_route_table_association" "rt_association_public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.eks_rt.id
}

resource "aws_route_table_association" "rt_association_public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.eks_rt.id
}
