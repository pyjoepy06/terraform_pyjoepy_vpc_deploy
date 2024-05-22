resource "aws_security_group" "lab_sg" {
  name        = "convergeone-default-sg"
  description = "Allow All Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow All Traffic Test Security Group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "convergeone-default-sg"
  }
}