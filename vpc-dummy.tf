resource "aws_vpc" "Test1-VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Test1-VPC"
  }
}

resource "aws_internet_gateway" "Test1-Gateway" {
  vpc_id = aws_vpc.Test1-VPC.id

  tags = {
    Name = "Test1-Gateway"
  }
}

resource "aws_route_table" "Test1-Route-Table" {
  vpc_id = aws_vpc.Test1-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Test1-Gateway.id
  }

  tags = {
    Name = "Test1-Route-Table"
  }
}

resource "aws_subnet" "Test1-Subnet" {
  vpc_id     = aws_vpc.Test1-VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Test1-Subnet"
  }
}

resource "aws_route_table_association" "Test1-RT-Assoc" {
  subnet_id      = aws_subnet.Test1-Subnet.id
  route_table_id = aws_route_table.Test1-Route-Table.id
}

resource "aws_security_group" "Test1-Security-Group" {
  name        = "Test1-Security-Group"
  description = "Allow Test1 traffic"
  vpc_id      = aws_vpc.Test1-VPC.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  tags = {
    Name = "Test1-Security-Group"
  }
}

resource "aws_network_interface" "Test1-NIC" {
  subnet_id       = aws_subnet.Test1-Subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.Test1-Security-Group.id]

  tags = {
    Name = "Test1-NIC"
  }
}

resource "aws_eip" "Test1-Elastic-IP" {
  vpc                       = true
  network_interface         = aws_network_interface.Test1-NIC.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.Test1-Gateway]

  tags = {
    Name = "Test1-Elastic-IP"
  }
}

resource "aws_key_pair" "Test1-Key-Pair" {
  key_name   = "Test1-Key-Pair"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOD+Wth7Qd6AtRCXOxhgKrXDqiu/1L2biYVzY1zLtXi1 stefan@nader.zone"
}

resource "aws_instance" "Test1-EC2-Instance" {
  ami           = "ami-065deacbcaac64cf2"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.Test1-Key-Pair.key_name
  
  network_interface {
    network_interface_id = aws_network_interface.Test1-NIC.id
    device_index         = 0
  }

  # user_data = file("./shell-scripts/ubuntu-init.sh")
  user_data = <<-EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
EOF

  tags = {
    Name = "Test1-EC2-Instance"
}


output "Test1-Pub-IP" {
  value       = aws_eip.Test1-Elastic-IP.public_ip
  description = "Public IP of Test1"
}
