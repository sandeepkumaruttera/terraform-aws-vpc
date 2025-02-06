variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {                                                 #optional that why we kept as map
    default = {}
}




# vpc

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}


variable "enable_dns_support" {
    type = bool
    default = "true"
}

variable "vpc_tags" {
    type = map
    default = {}
}

#IGW#

variable "igw_tags" {
    type = map
    default = {}
}


#public_subnets

variable "subnet_tags" {
    type = map
    default = {}
}


variable "public_subnet_cidr" {
    type = list
#        validation {
#       condition = length(var.public_subnet_cidr) == 2
#        error_message = "Please provide 2 valid public subnet CIDR"
#    }
}


#private_subnets

variable "private_subnet_cidr" {
    type = list
}


##database_subnet##

variable "database_subnet_cidr" {
    type = list 
    default = []
}

##natgateway###

variable "nat_tags" {                    # tags must be in maps
    type = map
    default = {} 
}


##route tables###

variable "public_route_table" {
    type = map
    default = {}
}

variable "private_route_table" {
    type = map
    default = {}
}

variable "database_route_table" {
    type = map
    default = {}
}



###default vpc_peering ###

variable "is_peering_required" {
    type = bool
    default = false
}

variable "peering_tags" {
    type = map
    default = {}
}















