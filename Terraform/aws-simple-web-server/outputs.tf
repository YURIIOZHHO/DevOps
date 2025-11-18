output "info_about_ec2" {
  value = aws_instance.ec2_instence.public_ip
}