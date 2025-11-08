data "aws_availability_zones" "available" {
  state = "available"
}

# -----VPC-----

resource "aws_vpc" "hotelapp-vpc-tf" {
  cidr_block       = var.cidr_block_vpc
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

# -----SUBNETS-----
# Create two public subnets in the first two available AZs
resource "aws_subnet" "hotelapp-subnets-public-tf" {
  count                   = 2
  vpc_id                  = aws_vpc.hotelapp-vpc-tf.id
  cidr_block              = cidrsubnet(var.cidr_block_vpc, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.map_public_ip

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# -----ROUTE-TABLES-----

resource "aws_route_table" "hotelapp-public-rt-tf" {
  vpc_id = aws_vpc.hotelapp-vpc-tf.id

  route {
    cidr_block = var.cidr_block_route_table_public
    gateway_id = aws_internet_gateway.hotelapp-igw-tf.id
  }
 tags = {
    Name = "hotelapp-public-rt-tf"
  }

}

resource "aws_route_table_association" "hotelapp-public-rt-association" {
  count          = 2
  subnet_id      = aws_subnet.hotelapp-subnets-public-tf[count.index].id
  route_table_id = aws_route_table.hotelapp-public-rt-tf.id
}


# -----IGW-----

resource "aws_internet_gateway" "hotelapp-igw-tf" {
  vpc_id = aws_vpc.hotelapp-vpc-tf.id

  tags = {
    Name = "hotelapp-igw-tf"
  }
}
