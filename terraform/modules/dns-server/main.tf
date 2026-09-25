data "aws_ssm_parameter" "al2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_iam_role" "this" {
  name = "${var.name_prefix}-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-dns-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-dns-profile"
  role = aws_iam_role.this.name

  tags = {
    Name = "${var.name_prefix}-dns-profile"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-dns-sg"
  description = "Authoritative DNS on UDP/TCP 53 plus HTTPS for SSM"
  vpc_id      = var.vpc_id

  ingress {
    description = "DNS UDP from allowed CIDRs"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "DNS TCP from allowed CIDRs"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "DNS UDP from outbound endpoint SG"
      from_port       = 53
      to_port         = 53
      protocol        = "udp"
      security_groups = var.allowed_security_group_ids
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "DNS TCP from outbound endpoint SG"
      from_port       = 53
      to_port         = 53
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  egress {
    description = "HTTPS for SSM and package repos"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-dns-sg"
  }
}

locals {
  zone_records = join("\n", [
    for name, ip in var.zone_records : "${name} IN A   ${ip}"
  ])

  # Lab assumes all A records share one /24 (10.0.100.0/24 → 100.0.10.in-addr.arpa).
  _first_ip_octets = split(".", values(var.zone_records)[0])
  reverse_zone_name = join(".", [
    local._first_ip_octets[2],
    local._first_ip_octets[1],
    local._first_ip_octets[0],
    "in-addr.arpa",
  ])

  ptr_records = join("\n", [
    for name, ip in var.zone_records :
    "${split(".", ip)[3]} IN PTR ${name}.${var.zone_name}."
  ])

  # Match BIND allow-query to the same CIDRs the SG permits (plus localhost).
  allow_query = join("; ", concat(var.allowed_cidr_blocks, ["localhost"]))

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    zone_name         = var.zone_name
    reverse_zone_name = local.reverse_zone_name
    private_ip        = var.private_ip
    zone_records      = local.zone_records
    ptr_records       = local.ptr_records
    allow_query       = local.allow_query
    soa_serial        = var.soa_serial
  })
}

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.al2023_arm64.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  iam_instance_profile        = aws_iam_instance_profile.this.name
  vpc_security_group_ids      = [aws_security_group.this.id]
  user_data                   = local.user_data
  user_data_replace_on_change = true

  associate_public_ip_address = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "${var.name_prefix}-dns"
  }
}
