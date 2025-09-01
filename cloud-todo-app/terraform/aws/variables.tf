variable "region" { type = string, default = "ap-south-1" }
variable "project" { type = string, default = "cloud-todo" }

variable "vpc_cidr" { type = string, default = "10.0.0.0/16" }
variable "public_subnets" { type = list(string), default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnets" { type = list(string), default = ["10.0.101.0/24", "10.0.102.0/24"] }

variable "db_username" { type = string, default = "postgres" }
variable "db_password" { type = string, default = "postgres" }
variable "db_instance_class" { type = string, default = "db.t3.micro" }
