resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.proj_vpc.id

  availability_zone = "us-east-1a"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = false
  
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.proj_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
}

resource "aws_route_table_association" "public_route_table_associate" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_eip" "eip_nat_gatway" {
  
  domain = "vpc"

}

resource "aws_nat_gateway" "nat_gateway" {
    subnet_id = aws_subnet.public_subnet.id
    allocation_id = aws_eip.eip_nat_gatway.id
}