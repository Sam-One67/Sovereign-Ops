# 1. Latest Amazon Linux 2023 AMI Finder
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
}

# 2. VPC & Networking
resource "aws_vpc" "sovereign_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "Sovereign-VPC" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sovereign_vpc.id
  tags   = { Name = "Sovereign-IGW" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.sovereign_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags                    = { Name = "Sovereign-Public-Subnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sovereign_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 3. Automated SSH Key Generation
resource "tls_private_key" "sovereign_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "sovereign-ops-key"
  public_key = tls_private_key.sovereign_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${path.module}/sovereign-ops-key.pem"
  content         = tls_private_key.sovereign_key.private_key_pem
  file_permission = "0400"
}

# 4. Security Group (Firewall)
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins port"
  vpc_id      = aws_vpc.sovereign_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Jenkins-SG" }
}

# 5. Jenkins Server (Latest Amazon Linux + t3.small)
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  tags = { Name = "Sovereign-Jenkins-Server" }
}