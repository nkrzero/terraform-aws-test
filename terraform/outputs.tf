# --- Values printed after apply, used to connect/test ---

output "instance_public_ip" {
  description = "Public IP of the EC2 VM"
  value       = aws_instance.web.public_ip
}

output "ssh_command" {
  description = "Ready-to-run SSH command"
  value       = "ssh -i ${var.ssh_private_key_path} ec2-user@${aws_instance.web.public_ip}"
}
