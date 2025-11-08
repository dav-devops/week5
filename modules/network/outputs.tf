output "vpc_id" {
  value = aws_vpc.hotelapp-vpc-tf.id
}

output "public_subnet_ids" {
  value = aws_subnet.hotelapp-subnets-public-tf[*].id
}

output "availability_zones_used" {
  value = data.aws_availability_zones.available.names
}
