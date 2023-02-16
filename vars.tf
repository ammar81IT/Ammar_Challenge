variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_apache" {
  default = "vpc-0a9c7716d08687e44" #VPC ID# 
}

variable "instance_key" {
  default = "keyname"
}

variable "vpc_cidr" {
  default = "10.0.1.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.2.0/16"
}
