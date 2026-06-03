resource "aws_key_pair" "gitlab" {
  key_name   = "gitlab"
  public_key = file("${path.module}/gitlab.pub")
}

resource "aws_instance" "gitlab-server" {
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t3.large"

  root_block_device {
    volume_size = 80
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "gitlab-server"
  }

  metadata_options {
    http_tokens = "required"
  }

  key_name               = aws_key_pair.gitlab.key_name
  vpc_security_group_ids = [aws_security_group.server.id]
}

resource "aws_instance" "gitlab-runner" {
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t3.medium"

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true
  }


  tags = {
    Name = "gitlab-runner"
  }

  metadata_options {
    http_tokens = "required"
  }

  key_name               = aws_key_pair.gitlab.key_name
  vpc_security_group_ids = [aws_security_group.runner.id]
}


resource "aws_instance" "sonarqube" {
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t2.medium"

  tags = {
    Name = "sonarqube"
  }

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
    encrypted   = true
  }

  key_name               = aws_key_pair.gitlab.key_name
  vpc_security_group_ids = [aws_security_group.sonarqube.id]
}