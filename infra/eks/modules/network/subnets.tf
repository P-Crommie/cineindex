#Public Subnets
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                           = "${var.env}-${var.project}-publicSubnet-${count.index}"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }
  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                           = "${var.env}-${var.project}-privateSubnet-${count.index}"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }
}
