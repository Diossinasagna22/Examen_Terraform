provider "aws" {
  region = "us-east-1"
}

# Security Group pour autoriser HTTP et SSH
resource "aws_security_group" "nginx_sg" {
  name_prefix = "nginx-sg-"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "nginx-security-group"
  }
}

resource "aws_instance" "vm" {
  ami                    = "ami-0c7217cdde317cfec"  # Ubuntu Server 22.04 LTS - us-east-1
  instance_type          = "t3.micro"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "vm-aws-nginx"
  }
}

output "public_ip" {
  value = aws_instance.vm.public_ip
}
