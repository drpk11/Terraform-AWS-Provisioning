resource "aws_vpc" "terra_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "terra_vpc"
  }
}

resource "aws_subnet" "public_sb" {
  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = var.public_cidr_block
map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet"
  }
}

resource "aws_subnet" "private_sub" {
    vpc_id = aws_vpc.terra_vpc.id
    cidr_block = var.private_cidr_block
  tags = {
    Name = "Private_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "Internet_gateway"
  }
}
resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.terra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_route"
  }
  
  }
resource "aws_route_table_association" "associate_route" {
  subnet_id      = aws_subnet.public_sb.id
  route_table_id = aws_route_table.route1.id
}


resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.terra_vpc.id

  ingress {
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8080
    to_port   = 8080
  }
  ingress {
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Terra_EC2" {
  ami = var.ami_value
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_sb.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name = var.key_name
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
                sudo apt upgrade -y
                sudo apt install -y openjdk-17-jdk
                curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
                /usr/share/keyrings/jenkins-keyring.asc > /dev/null

                echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null


                sudo apt update -y
                sudo apt install -y jenkins

                sudo systemctl enable jenkins
                sudo systemctl start jenkins
                sudo systemctl status jenkins
              EOF
 tags = {
   Name = "Jenkins_server_ec2"
 }
}

