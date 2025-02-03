resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.proj_vpc.id

  availability_zone = "us-east-1b"
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = false

}

resource "aws_route_table" "public_route_table2" {
    vpc_id = aws_vpc.proj_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
}

resource "aws_route_table_association" "public_route_table_associate2" {
  subnet_id = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table2.id
}


resource "aws_eip" "eip_nat_gatway2" {
  
  domain = "vpc"

}

resource "aws_nat_gateway" "nat_gateway2" {
    subnet_id = aws_subnet.public_subnet2.id
    allocation_id = aws_eip.eip_nat_gatway2.id
}