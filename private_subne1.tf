resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.proj_vpc.id

  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  assign_ipv6_address_on_creation = false

}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.proj_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }
}

resource "aws_route_table_association" "private_route_table_associate" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}


