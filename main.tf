resource "aws_vpc" "devops_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = var.vpc_name
    }
}

resource "aws_subnet" "devops_public_subnet1" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = var.subnet1_cidr
    availability_zone = var.my_az_region1
    map_public_ip_on_launch = true
    tags = {
        Name = var.public_subnet1_name
    }
}

resource "aws_subnet" "devops_public_subnet2" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = var.subnet2_cidr
    availability_zone = var.my_az_region2
    map_public_ip_on_launch = true
    tags = {
        Name = var.public_subnet2_name
    }
  
}

resource "aws_subnet" "devops_private_subnet1" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = var.subnet3_cidr
    availability_zone = var.my_az_region1
    tags = {
        Name = var.private_subnet1_name
    }
}

resource "aws_subnet" "devops_private_subnet2" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = var.subnet4_cidr
    availability_zone = var.my_az_region2
    tags = {
        Name = var.private_subnet2_name
    }
}

resource "aws_internet_gateway" "devops_igw" {
    vpc_id = aws_vpc.devops_vpc.id
    tags = {
        Name = var.my_igw
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.devops_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops_igw.id
    }
    tags = {
        Name = var.public_route_table_name
    }
}

resource "aws_route_table_association" "assoc1" {
    subnet_id = aws_subnet.devops_public_subnet1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "assoc2" {
    subnet_id = aws_subnet.devops_public_subnet2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "devops_eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "devops_natgw" {
    allocation_id = aws_eip.devops_eip.id
    subnet_id = aws_subnet.devops_public_subnet1.id
    tags = {
        Name = var.natgw_name
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.devops_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.devops_natgw.id
    }
    tags = {
        Name = var.private_route_table_name
    }
}

resource "aws_route_table_association" "private_assoc1" {
    subnet_id = aws_subnet.devops_private_subnet1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_assoc2" {
    subnet_id = aws_subnet.devops_private_subnet2.id
    route_table_id = aws_route_table.private_route_table.id
}





resource "aws_security_group" "launch_template_sg" {
    vpc_id = aws_vpc.devops_vpc.id
    name = "launch_template_sg"
    description = "Security group for launch template"
    tags = {
        Name = var.my_sg_name
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"    
        cidr_blocks = ["0.0.0.0/0"] 
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" 
        cidr_blocks = ["0.0.0.0/0"] 
    }
}

resource "aws_instance" "custom_ami_instance" {
  ami           = var.base_ami_id  
  instance_type = var.instance_type_for_custom_ami
  subnet_id     = aws_subnet.devops_public_subnet1.id
  vpc_security_group_ids = [aws_security_group.launch_template_sg.id]
  key_name = "rakeshrr"

  tags = {
    Name = "custom-ami-instance"
  }

  provisioner "remote-exec" {
    connection {
    type        = "ssh"
    user        = "ec2-user"  
    private_key = file("./rakeshrr")  
    host        = self.public_ip
  }

    inline = [
      "sudo yum update -y",              
      "sudo yum install -y httpd",       
      "sudo systemctl enable httpd",     
      "sudo systemctl start httpd",      
       
      "echo 'Hey guys we successfully auto scaled' | sudo tee /var/www/html/index.html"
    ]
  }
}


resource "aws_ami_from_instance" "custom_ami" {
  name               = "customised-ami-with-httpd-and-code"
  source_instance_id        = aws_instance.custom_ami_instance.id
    tags = {
        Name = "customised-ami-with-httpd-and-code"
    }
    depends_on = [aws_instance.custom_ami_instance]
}


resource "aws_launch_template" "custom_lt" {
  name          = "custom-launch-template"
  image_id      = aws_ami_from_instance.custom_ami.id  
  instance_type = var.instance_type_for_lt
  key_name      = var.my_key
  vpc_security_group_ids = [aws_security_group.launch_template_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "custom-instance"
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"  
    ebs {
      volume_size = 8  
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

}


resource "aws_security_group" "alb_sg" {
    name = "alb_security_group"
    vpc_id = aws_vpc.devops_vpc.id
    description = "Used in the DevOps project and allow traffic on port 80 and port 22"
    tags = {
        Name = var.alb_sg_name
    }

    ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"   
        cidr_blocks = ["0.0.0.0/0"] 
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"    
        cidr_blocks = ["0.0.0.0/0"] 
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" 
        cidr_blocks = ["0.0.0.0/0"] 
    }
  
}

resource "aws_lb" "devops_alb" {
    load_balancer_type = var.my_load_balancer_type
    name = "devops-alb"
    internal = false
    security_groups = [aws_security_group.alb_sg.id]
    subnets = [aws_subnet.devops_public_subnet1.id, aws_subnet.devops_public_subnet2.id]
    enable_deletion_protection = false
    idle_timeout = 400
    tags = {
        Name = var.my_alb_name
    }
}

resource "aws_lb_target_group" "devops_target_group" {
    name = "devops-tg"
    port = 80
    protocol = "HTTP"
    target_type = var.targets
    vpc_id = aws_vpc.devops_vpc.id

    health_check {
        path = "/"
        port = 80
        protocol = "HTTP"
        timeout = 5
        interval = 30
        healthy_threshold = 2
        unhealthy_threshold = 2
    }

    tags = {
        Name = var.my_target_group_name
    }
}

resource "aws_lb_listener" "devops_listener" {
    load_balancer_arn = aws_lb.devops_alb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.devops_target_group.arn
    }
}


resource "aws_autoscaling_group" "devops_asg" {
    name = "devops-asg"
    desired_capacity = var.desired
    max_size = var.maximum
    min_size = var.minimum
    vpc_zone_identifier = [aws_subnet.devops_public_subnet1.id, aws_subnet.devops_public_subnet2.id]
    
    launch_template {
         id = aws_launch_template.custom_lt.id
         version = "$Latest"
    }
    target_group_arns = [aws_lb_target_group.devops_target_group.arn]
    health_check_type = "ELB"
    health_check_grace_period = 300
    termination_policies = ["OldestInstance"]
    tag {
            key = "Name"
            value = "devops-application"
            propagate_at_launch = true
        }
    depends_on = [ aws_launch_template.custom_lt ]
}




