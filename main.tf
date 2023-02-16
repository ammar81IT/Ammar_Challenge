resource "aws_instance" "web" {
  region = var.region
  ami             = "ami-0dfcb1ef8550277af" 
  instance_type   = var.instance_type
  key_name        = var.instance_key
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id] 

  user_data = <<-EOF
  #!/bin/bash
  echo  "Installing apache"
  sudo yum update -y
  sudo yum install httpd -y
  sudo systemctl start httpd 
  echo "Completed Installing apache"
  echo "Installing vim"
  sudo yum install vim -y 
  echo "Vim installed" 
  echo "Installing coreutils package"
  sudo yum install coreutils -y
  echo "Coreutils installed"
  echo "echo "<h1>hello world</h1>" | sudo tee /var/www/html/index.html
  EOF

  tags = {
    Name = "Apache_web_instance"
  }
}

resource "aws_vpc" "web_app_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "web_app-vpc"
  }
}

resource "aws_security_group" "sg" {
  name        = "Allow_ssh_http redirecting to https"
  description = "Allow ssh and redirecting http traffic to https"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] #*****MY elastic IP ADDRESS, NOT 0.0.0.0/0*****
  }

  ingress {
    from_port        = 80
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

#Would deploy and test my code but using terraform validate, terraform fmt (readability), terraform plan (check resources that will be applied), terraform apply (WILL SEE ERRORS IN CODE IF UNSUCCESSFUL)
