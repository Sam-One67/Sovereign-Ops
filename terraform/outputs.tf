output "jenkins_public_ip" {
  value       = aws_instance.jenkins_server.public_ip
  description = "Public IP of the Jenkins Server"
}

output "vpc_id" {
  value = aws_vpc.sovereign_vpc.id
}

output "ssh_key_location" {
  value       = local_file.ssh_key.filename
  description = "Path to your private SSH key"
}