variable "my_region" {
    description = "Enter your region where you want your infrastructure"
}

variable "vpc_cidr" {
    description = "Enter the CIDR block for your VPC"
}

variable "vpc_name" {
    description = "Enter the name of your VPC"
}

variable "subnet1_cidr" {
    description = "Enter the CIDR block for your subnet1"
}

variable "my_az_region1" {
    description = "Enter the 1st availability zone for your public subnet"
}

variable "public_subnet1_name" {
    description = "Enter the name of your public subnet 1" 
}

variable "subnet2_cidr" {
    description = "Enter the CIDR block for your subnet2"
}

variable "my_az_region2" {
    description = "Enter the 2nd availability zone for your public subnet"
}

variable "public_subnet2_name" {
    description = "Enter the name of your public subnet 2" 
}

variable "subnet3_cidr" {
    description = "Enter the cidr range for private subnet1"
}

variable "private_subnet1_name" {
    description = "Enter the name of your private subnet 1"
}

variable "subnet4_cidr" {
    description = "Enter the cidr range for private subnet 2"
}

variable "private_subnet2_name" {
    description = "Enter the name of your private subnet 2"
}

variable "my_igw" {
    description = "Enter your internet gateway name"
}

variable "public_route_table_name" {
    description = "Enter the name for your public route table"
}

variable "natgw_name" {
    description = "Enter the name of your natgw"
}

variable "private_route_table_name" {
    description = "Enter the name for your private route table"
}


# ---------- variable declaration for auto scaling group ----------



variable "my_sg_name" {
  description = "The name of the security group"
}

variable "alb_sg_name" {
  description = "The name of the security group"
}

variable "my_load_balancer_type" {
  description = "value of the load balancer type"  
}

variable "my_alb_name" {
  description = "The name of the Application Load Balancer"  
}

variable "targets" {
  description = "The list of targets to register with the target group"
}

variable "my_target_group_name" {
  description = "The name of the target group"
}

variable "base_ami_id" {
  description = "The base AMI ID to use for the EC2 instances"
}

variable "instance_type_for_custom_ami" {
  description = "The instance type to use for the EC2 instances"
}

variable "my_subnet_id_for_custom_ami" {
  description = "The subnet ID to use for the EC2 instances"
}

variable "instance_type_for_customised_ami_with_httpd" {
  description = "The instance type to use for the EC2 instances"
  
}

variable "instance_type_for_lt" {
  description = "The instance type to use for the EC2 instances"
  
}
variable "my_key" {
  description = "The name of the private key to use for the EC2 instances"
  
}

variable "desired" {
    description = "Enter desired instances"
}

variable "maximum" {
    description = "Enter maximum instances"
}

variable "minimum" {
    description = "Enter minimum instances"
}
