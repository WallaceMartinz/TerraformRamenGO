/*==== Criando a VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block                = "10.0.0.0/24"
  enable_dns_hostnames      = true
  enable_dns_support        = true
  tags = {
    Name                    = "vpc-applicationrv"
  }
}

/*==== internet gateway igw ====*/
resource "aws_internet_gateway" "igw" {
  vpc_id                    = aws_vpc.vpc.id
  tags = {
    Name                    = "igw-applicationrv"
  }
}

/*==== sub-rede pública ====*/
resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.public_subnet_cidrs
    map_public_ip_on_launch = true
    availability_zone       = var.a_zone
    tags = {
      Name                  = "sub-rede-applicationrv"
    }  
}


/*==== tabela de rota pública ====*/
resource "aws_route_table" "public_rt" {
    vpc_id                  = aws_vpc.vpc.id
    route {
      cidr_block            = "0.0.0.0/0"
      gateway_id            = aws_internet_gateway.igw.id
    }
    tags = {
      Name                  = "rt-applicationrv"
 }
}
resource "aws_route_table_association" "public" {
    route_table_id          = aws_route_table.public_rt.id
    subnet_id               = aws_subnet.public_subnet.id
}


/*==== criando ACL ====*/ 
resource "aws_network_acl" "acl_applicationrv" {
  vpc_id                    = aws_vpc.vpc.id
  subnet_ids                = [ aws_subnet.public_subnet.id]
  ingress { # permitindo SSH
    protocol                = "tcp"
    rule_no                 = 100
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 22
    to_port                 = 22
  }
  ingress { # permitindo http
    protocol                = "tcp"
    rule_no                 = 200
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 80
    to_port                 = 80
  }
  ingress { # permitindo https
    protocol                = "tcp"
    rule_no                 = 300
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 443
    to_port                 = 443
  }
  ingress { # permitindo https
    protocol                = "tcp"
    rule_no                 = 400
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 8080
    to_port                 = 8080
  }
  ingress { # permitindo retorno de entrada internet
    protocol                = "tcp"
    rule_no                 = 500
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 32000
    to_port                 = 65535
  }
  egress { # Permite saída para todo tráfego
    protocol                = "-1"
    rule_no                 = 100
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 0
    to_port                 = 0
  }
  tags = {
    Name                    = "acl_ramengo"
  }
}


/*==== Criando Security Group ====*/
resource "aws_security_group" "sg" {
  name                      = "basic_security"
  description               = "Allow SSH/HTTP/HTTPS access"
  vpc_id                    = aws_vpc.vpc.id
  ingress {
    from_port               = "22"
    to_port                 = "22"
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    from_port               = "80"
    to_port                 = "80"
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    from_port               = "8080"
    to_port                 = "8080"
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    from_port               = "443"
    to_port                 = "443"
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
}

output "subnet_public_id" {
    value = aws_subnet.public_subnet.id
}
output "vpc_id" {
    value = aws_vpc.vpc.id
}
output "igw_id" {
    value = aws_internet_gateway.igw.id
}
