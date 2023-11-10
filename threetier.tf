provider "aws" {
  access_key="----------"
  secret_key= "----------"
  region     = "ap-south-1"
}

# creating custom vpc
resource "aws_vpc" "custom-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "custom-vpc"
  }
}
# Creating IGW
resource "aws_internet_gateway" "custom-igw" {
  vpc_id = aws_vpc.custom-vpc.id

  tags = {
    Name = "custom-igw"
  }
}

# Creating websubnet
resource "aws_subnet" "websubnet" {
 cidr_block = "10.0.0.0/20"
 availability_zone = "ap-south-1a"
 vpc_id = aws_vpc.custom-vpc.id

  tags = {
    Name = "subnet for ap-south-1a"
  }
}

# Creating appsubnet
resource "aws_subnet" "appsubnet" {
 cidr_block = "10.0.16.0/20"
 availability_zone = "ap-south-1b"
 vpc_id = aws_vpc.custom-vpc.id

  tags = {
    Name = "subnet for ap-south-1b"
  }
}

# Creating dbsubnet
resource "aws_subnet" "dbsubnet" {
 cidr_block = "10.0.32.0/20"
 availability_zone = "ap-south-1a"
 vpc_id = aws_vpc.custom-vpc.id

  tags = {
    Name = "subnet for ap-south-1a"
  }
}

# creating Private RT
resource "aws_route_table" "public-rt" {
  vpc_id  = aws_vpc.custom-vpc.id
  route {
    cidr_block= "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom-igw.id
  }
}
resource "aws_route_table" "pvt-rt" {
  vpc_id  = aws_vpc.custom-vpc.id
}

# Creating public association
resource "aws_route_table_association" "public_association" {
    subnet_id = aws_subnet.websubnet.id
    route_table_id = aws_route_table.public-rt.id
}

# Creating private association
resource "aws_route_table_association" "private_association-app" {
    subnet_id = aws_subnet.appsubnet.id
    route_table_id = aws_route_table.pvt-rt.id
}
resource "aws_route_table_association" "private_association-db" {
    subnet_id = aws_subnet.dbsubnet.id
    route_table_id = aws_route_table.pvt-rt.id
}

# creating Websg
resource "aws_security_group" "web-sg" {
vpc_id = aws_vpc.custom-vpc.id
 name="web-sg"
ingress {
 from_port=80
 to_port=80
protocol="tcp"
cidr_blocks= ["0.0.0.0/0"]
}

ingress {
 from_port=22
 to_port=22
protocol="tcp"
cidr_blocks= ["0.0.0.0/0"]
}
egress {
 from_port=0
 to_port=0
protocol="-1"
cidr_blocks= ["0.0.0.0/0"]
}
}
 # Creating appsg
resource "aws_security_group" "app-sg" {
vpc_id = aws_vpc.custom-vpc.id
 name="app-sg"
ingress {
 from_port=9000
 to_port=9000
protocol="tcp"
cidr_blocks= ["10.0.0.0/20"]
}

egress {
 from_port=0
 to_port=0
protocol="-1"
cidr_blocks= ["0.0.0.0/0"]
}
}
# Creating dbsg
resource "aws_security_group" "db-sg" {
vpc_id = aws_vpc.custom-vpc.id
 name="db-sg"
ingress {
 from_port=3306
 to_port=3306
protocol="tcp"
cidr_blocks= ["10.0.16.0/20"]
}

egress {
 from_port=0
 to_port=0
protocol="-1"
cidr_blocks= ["0.0.0.0/0"]
}
}
# Creating webec2 instance
resource "aws_instance" "webec2" {
  ami           = "ami-02e94b011299ef128"
  instance_type = "t2.micro"
  vpc_security_group_ids=[aws_security_group.web-sg.id]
  key_name="tf-key-pair"
  subnet_id = aws_subnet.websubnet.id

tags={
 Name="web-server"
}
}

# Creating appec2 instance
resource "aws_instance" "appec2" {
  ami           = "ami-02e94b011299ef128"
  instance_type = "t2.micro"
  vpc_security_group_ids=[aws_security_group.app-sg.id]
  key_name="tf-key-pair"
  subnet_id = aws_subnet.appsubnet.id

tags={
 Name="app-server"
}
}

# Creating dbec2 instance
resource "aws_db_instance" "dbec2" {
engine = "mysql"
instance_class = "db.t3.micro"
allocated_storage = 20
storage_type= "gp2"
username= "root"
password= "Pass1234"
vpc_security_group_ids=[aws_security_group.db-sg.id]
identifier= "myrds"
db_subnet_group_name= aws_db_subnet_group.mydbsubnetgroup.id
tags={
 Name="db-server"
}
}
resource "aws_db_subnet_group" "mydbsubnetgroup" {
name= "mydbsubnetgroup"
subnet_ids= [aws_subnet.dbsubnet.id, aws_subnet.appsubnet.id]
description= "db-subnet-group"
}

# Creating Key pair
resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}
