
output "vpc_id" {
  value = aws_vpc.terra_vpc.id
}
output "igw" {
  value = aws_internet_gateway.igw.id
}
output "jenkins_ec2_public_ip" {
  description = "Public IP address of the EC2 instance running Jenkins"
  value       = aws_instance.Terra_EC2.public_ip
}
