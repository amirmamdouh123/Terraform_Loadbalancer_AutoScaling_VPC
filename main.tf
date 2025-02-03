
provider "aws" {
  
  region = "us-east-1"
}


resource "aws_vpc" "proj_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name= "proj_vpc"
    }

}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.proj_vpc.id
}



data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["137112412989"] # Amazon
}



# Load balancer , Listener , Target Group  

resource "aws_lb" "ec2_lb" {
  name = "ec2lb"
  subnets = [ aws_subnet.public_subnet.id , aws_subnet.public_subnet2.id ]
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.lb_security_group.id ]

}


resource "aws_lb_target_group" "ec2_target_group" {
  name= "ec2targetgroup"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.proj_vpc.id


  health_check {        # Related to Auto scling health check       -> if failed -> Unhealthy
    port = 80
    path = "/"
    timeout = 5
    interval = 30
    healthy_threshold = 3
    unhealthy_threshold = 3
  }

}

resource "aws_lb_listener" "ec2_lb_listener" {              # connects the lb with target group
 load_balancer_arn = aws_lb.ec2_lb.arn
 default_action {
  target_group_arn = aws_lb_target_group.ec2_target_group.arn
  type = "forward"
 }
 port=80 
 protocol = "HTTP"
}



resource "aws_launch_template" "aws_launch_ec2" {
  name         = "ec2launchltemplate"
  image_id      = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"

      user_data = base64encode(<<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
                sudo yum openshh-server -y
                sudo systemctl enable sshd
                echo "Hello World From Host: $(hostname -I)" > /var/www/html/index.html
                EOF
                )
  

  vpc_security_group_ids = [aws_security_group.lb_security_group.id]  # Add this line
  

  key_name = aws_key_pair.key_pair.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10
      volume_type = "gp2"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "EC2-From-Launch-Template"
    }
  }
  
}




resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "terraform-key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "terraform-key.pem"
  content         = tls_private_key.private_key.private_key_pem
  file_permission = "0600"
}



resource "aws_autoscaling_group" "ec2_autosacaling_group" {
  
  name = "ec2autosacaling_group"

  launch_template {
    id = aws_launch_template.aws_launch_ec2.id
  }

  target_group_arns = [ aws_lb_target_group.ec2_target_group.arn]
  min_size = 1
  max_size = 2
  desired_capacity = 1
  vpc_zone_identifier = [ aws_subnet.private_subnet.id , aws_subnet.private_subnet2.id ]      #

}



#Alarm if the CPU Utilization more than 70 
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "scale-up-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = 60
  statistic          = "Average"
  threshold          = 70
  alarm_description  = "Triggers scaling up when CPU exceeds 70%."
  actions_enabled    = true

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_autosacaling_group.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}


resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 60
  autoscaling_group_name = aws_autoscaling_group.ec2_autosacaling_group.name # execute the action on which Auto scaling group
}




#Alarm if the CPU Utilization less than 30 
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "scale-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = 60
  statistic          = "Average"
  threshold          = 30
  alarm_description  = "Triggers scaling down when CPU falls below 30%."
  actions_enabled    = true

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_autosacaling_group.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

#autoscaling policy that do the actual action on the Autoscaling target group
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 60
  autoscaling_group_name = aws_autoscaling_group.ec2_autosacaling_group.name
}

