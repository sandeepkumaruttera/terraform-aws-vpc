resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block              #it is fixed u can check in variable
  instance_tenancy = "default"
  enable_dns_support = var.enable_dns_support

  tags = merge (
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.vpc_name
    }
  )
}

#IGW###

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.igw_tags,
    {
        Name = local.vpc_name
    }
  )
}

##public_subnets##

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone = local.availability_zone[count.index]
  cidr_block = var.public_subnet_cidr[count.index]
  tags = merge (
    var.common_tags,
    var.subnet_tags,
    {
        Name = "${local.vpc_name}-public-${local.availability_zone[count.index]}"
    }
  )
}


# this is the simple way to understand below one just read that it ##


#resource "aws_subnet" "public" {
#  vpc_id     = aws_vpc.main.id
#  availability_zone = data.aws_availability_zones.available.names[1]
#  cidr_block = 10.0.11.0/24
#      tags = merge (
#    var.common_tags,
#    var.subnet_tags,
#    {
#        Name = "${local.vpc_name}-public-us-east-1b"
#    }
#  )
#}

#private_subnets##

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone = local.availability_zone[count.index]
  cidr_block = var.private_subnet_cidr[count.index]
  tags = merge (
    var.common_tags,
    var.subnet_tags,
    {
        Name = "${local.vpc_name}-private-${local.availability_zone[count.index]}"
    }
  )
}


#database subnets##


resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone = local.availability_zone[count.index]
  cidr_block = var.database_subnet_cidr[count.index]
  tags = merge (
    var.common_tags,
    var.subnet_tags,
    {
        Name = "${local.vpc_name}-database-${local.availability_zone[count.index]}"
    }
  )
}


##database default route table###

resource "aws_db_subnet_group" "default" {
  subnet_ids = aws_subnet.database[*].id                ##i tried with count but did'nt work here so kept * instead of count = length ()###
  tags = merge (
    var.common_tags,
    var.subnet_tags,
    {
        Name = "${local.vpc_name}"
    }
  )
}



#elastic ip#


resource "aws_eip" "nat" {                       #elastic ip = static ip it is stable never change ip address
  domain   = "vpc"
}

#natgateway##

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id                             #u can see here natgateway attched to public subnet 

  tags = merge (
    var.common_tags,
    var.nat_tags,
    {
        Name = "${local.vpc_name}"
    }
  )  



  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


##route tables###

#public_route_table

resource "aws_route_table" "public" {
  vpc_id     = aws_vpc.main.id

    tags = merge (
    var.common_tags,
    var.public_route_table,
    {
        Name = "${local.vpc_name}-public"
    }
  )
}


resource "aws_route_table" "private" {
  vpc_id     = aws_vpc.main.id

    tags = merge (
    var.common_tags,
    var.private_route_table,
    {
        Name = "${local.vpc_name}-private"
    }
  )
}


resource "aws_route_table" "database" {
  vpc_id     = aws_vpc.main.id

    tags = merge (
    var.common_tags,
    var.database_route_table,
    {
        Name = "${local.vpc_name}-database"
    }
  )
}


###route tables associates with gateway_id and nat_gateway_id , public need only internet gateway becuase natgateway is public route only remaining required nat gateway


resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"                                             # it is called internet cidr_block
  gateway_id     = aws_internet_gateway.gw.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"                                             # it is called internet cidr_block
  nat_gateway_id     = aws_nat_gateway.nat.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"                                             # it is called internet cidr_block
  nat_gateway_id     = aws_nat_gateway.nat.id
}



###route tables association with subnets associations### will called it as roads

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}










