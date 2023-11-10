# this will help display getting the public/private ip or any thing that we have asked for just need to give specifications 

output "myec2ip" {
value= aws_instance.myec2.public_ip
}
