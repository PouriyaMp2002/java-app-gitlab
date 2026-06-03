# Define Security groups

resource "aws_security_group" "server" {
  name        = "gitlab-server-sg"
  description = "Security group for gitlab server"

  tags = {
    Name = "gitlab-server-sg"
  }
}

resource "aws_security_group" "runner" {
  name        = "gitlab-runner-sg"
  description = "Security group for gitlab runner"

  tags = {
    Name = "gitlab-runner-sg"
  }
}


resource "aws_security_group" "sonarqube" {
  name        = "sonar-sg"
  description = "Security group for sonarqube"

  tags = {
    Name = "sonarqube-sg"
  }
}

# Ingress Rules

resource "aws_vpc_security_group_ingress_rule" "gitlab-server-ssh" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "gitlab-server-http" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "gitlab-server-https" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}


resource "aws_vpc_security_group_ingress_rule" "gitlab-runner-ssh" {
  security_group_id = aws_security_group.runner.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}


resource "aws_vpc_security_group_ingress_rule" "sonar-ssh" {
  security_group_id = aws_security_group.sonarqube.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "sonar-port" {
  security_group_id = aws_security_group.sonarqube.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "tcp"
  from_port         = 9000
  to_port           = 9000
}

resource "aws_vpc_security_group_ingress_rule" "sonar-from-runner" {
  security_group_id            = aws_security_group.sonarqube.id
  referenced_security_group_id = aws_security_group.runner.id
  ip_protocol                  = "tcp"
  from_port                    = 9000
  to_port                      = 9000
}


# Egress Rules

resource "aws_vpc_security_group_egress_rule" "gitlab-server-out" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_egress_rule" "gitlab-runner-out-http" {
  security_group_id = aws_security_group.runner.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "sonar-out" {
  security_group_id = aws_security_group.sonarqube.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}
