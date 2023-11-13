provider "aws" {
  access_key=" "
  secret_key= " "
 region= "ap-south-1"
}


resource "aws_launch_configuration" "example" {
  image_id        = "ami-0d4a95b1465752c8c"   #add your aim id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
 lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "instance" {
  name = "rterraform-example-instance"
ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
 from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}
