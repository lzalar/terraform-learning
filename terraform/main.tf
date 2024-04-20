provider "aws" {
  region = "us-east-2"
}

variable "server_port" {
  description = "Port where the server will listen"
  default = 8080
  type = number
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}

resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t3.micro"
  tags          = {
    Name = "terraform-example"
  }
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data_replace_on_change = true

  user_data = <<-EOF
                #!/bin/bash
                   echo "Hello, World" > index.html
                   nohup busybox httpd -f -p ${var.server_port} &
                EOF
}

resource "aws_security_group" "instance" {
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
