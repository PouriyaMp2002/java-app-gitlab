output "gitlab-server-private-ip" {
  value = aws_instance.gitlab-server.private_ip
}

output "gitlab-server-public-ip" {
  value = aws_instance.gitlab-server.public_ip
}

output "gitlab-runner-private-ip" {
  value = aws_instance.gitlab-runner.private_ip
}

output "gitlab-runner-public-ip" {
  value = aws_instance.gitlab-runner.public_ip
}


output "sonarqube-private-ip" {
  value = aws_instance.sonarqube.private_ip
}

output "sonarqube-public-ip" {
  value = aws_instance.sonarqube.public_ip
}
