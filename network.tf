module "eks" {
  source          = "./modules/eks"
  
  iam_name  = "eks-cluster-role"
  iam_tags  = { Environment = "dev", Project = "eks" }

  # Cluster Configuration
  cluster_name              = "test-cluster"
  subnet_ids                = [aws_subnet.public-subnet.id, aws_subnet.private-subnet.id]
  security_group_ids        = [aws_security_group.node_group_sg.id]

  private_endpoint          = false
  public_endpoint           = true
  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  enable_cluster_creator_admin_permissions = true

  # KMS Encryption
  enable_kms         = false

  region = "ap-southeast-1"
  node_group_role_arn = module.node_group.node_group_role_arn
  config_output_path = "/Users/vidhiyadav/.kube/"


  # Authentication Mode
  authentication_mode = "API"

  # Tags
  cluster_tags = { Owner = "Vidhi", Team = "DevOps" }
}

module "node_group" {
  source          = "./modules/node_group"
}


resource "aws_vpc" "k8svpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_internet_gateway" "k8svpc-igw" {
  vpc_id = aws_vpc.k8svpc.id

  tags = {
    Name = "k8s-vpc-igw"
  }
}

# public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = "192.168.64.0/19"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name                         = "public-subnet"
  }
}


# private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = "192.168.32.0/19"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name                         = "private-subnet"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "k8s-nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "k8s-nat"
  }

  depends_on = [aws_internet_gateway.k8svpc-igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.k8svpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.k8s-nat-gw.id
    }
  

  tags = {
    Name = "k8s_private_rt"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.k8svpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.k8svpc-igw.id
    }

  tags = {
    Name = "k8s_public_rt"
  }
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private_rt.id
}

#Security Group for Node Group
resource "aws_security_group" "node_group_sg" {
  name        = "eks-node-group-sg"
  description = "Security group for EKS Node Group"
  vpc_id      = aws_vpc.k8svpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.trusted_ip]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "eks-node-group-sg" }
}



