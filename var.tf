# add this  var.tf file in main file where port is given
#WE can also add cidr clock
variable "publiccidr"{
type = list(string)
default = ["0.0.0.0/0"]
}
variable "server_port"{
type = number
default = 80
}
