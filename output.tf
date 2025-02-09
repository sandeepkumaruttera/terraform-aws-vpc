output "vpc_id" {
    value = aws_vpc.main.id
}

#output "data_source" {
#    value = data.aws_availability_zones.available
#}


output "vpc_peering" {
    value = aws_vpc_peering_connection.peering
}

output "vpc_publicsubnet_id" {
    value = aws_subnet.public[*].id
}

output "vpc_privatesubnet_id" {
    value = aws_subnet.private[*].id
}

output "vpc_databasesubnet_id" {
    value = aws_subnet.database[*].id
}
 
output "database_subnet_group_name" {
  value = aws_db_subnet_group.default.name
} 

