# NAT Elastic IP
resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "${var.env}-${var.project}-InternetGateWay-ElaticIP"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.env}-${var.project}-Nat-GateWay"
  }
  depends_on = [aws_internet_gateway.this]
}