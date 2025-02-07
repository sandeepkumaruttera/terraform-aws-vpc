output "vpc_id" {
    value = aws_vpc.main
}

#output "data_source" {
#    value = data.aws_availability_zones.available
#}


output "vpc_peering" {
    value = aws_vpc_peering_connection.peering
}

