# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env}-${var.project}-InternetGateWay"
  }
  depends_on = [aws_vpc.this]
}