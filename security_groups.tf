resource "aws_security_group" "lb_security_group" {
  
    name = "lb_security_group"
    vpc_id = aws_vpc.proj_vpc.id
    ingress {

        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"

    }

      ingress {

        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"

    }

    egress {

        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
        
    }

}