resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "terraform_vpc"
    Environment = "stage"
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.0.0/26"
  map_public_ip_on_launch = "true"
  availability_zone="ap-south-1a"

  tags = {
    Name = "terraform_pub_subnet1"
    Environment = "stage"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.0.64/26"
  availability_zone="ap-south-1a"

  tags = {
    Name = "terraform_priv_subnet1"
    Environment = "stage"
  }
}
resource "aws_subnet" "subnet3" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.0.128/26"
  map_public_ip_on_launch = "true"
  availability_zone="ap-south-1b"

  tags = {
    Name = "terraform_pub_subnet2"
    Environment = "stage"
  }
}
resource "aws_subnet" "subnet4" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.0.192/26"
  availability_zone="ap-south-1b"

  tags = {
    Name = "terraform_priv_subnet2"
    Environment = "stage"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform_igw"
    Environment = "stage"
  }
}
resource "aws_eip" "eip" {
  vpc      = true

  tags = {
    Name = "terraform_eip"
    Environment = "stage"
  }
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet2.id

  tags = {
    Name = "terraform_ngw"
    Environment = "stage"
  }
}
resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform_public_route"
    Environment = "stage"
  }
}
resource "aws_route_table" "priv_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "terraform_private_route"
    Environment = "stage"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.pub_route.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.pub_route.id
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.priv_route.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.priv_route.id
}