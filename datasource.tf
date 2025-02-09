data "aws_availability_zones" "available" {
  state = "available"
}

###it si deafult vpc source #### 

# data source querining provider it is default VPC must be default = true 

data "aws_vpc" "default" {                                           
  default = true
}


#data source quering the default route main table 


data "aws_route_table" "main" {                                                   #never ever change default systax even single word also
  vpc_id = data.aws_vpc.default.id                                                ## means it is default route table connecting to vpc_id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

