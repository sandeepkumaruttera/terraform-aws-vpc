resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0 
  peer_vpc_id   = data.aws_vpc.default.id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true                                                     # accepting both vpc request to comminicate each other if not accept they will not comminicate

    tags = merge (
    var.common_tags,
    var.peering_tags,                    # its a map 
    {
        Name = local.vpc_name
    }
  )
}

###route_table #### association

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0  
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1 : 0  
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}


resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1 : 0  
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block                                    #this one is default vpc_peering
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}



####main route table with vpc_main 

 ### it is adding default route table to our vpc created one ####

resource "aws_route" "default_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.id
  destination_cidr_block    = var.cidr_block                                                   #we created vpc need to take cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}





