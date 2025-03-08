output "vpc_id" {
    value = aws.vpc1.id
}
output "lb_sg_id" {
    value = aws_security_group.lb_sg.id
}
output "ps1id" {
 value = aws_subnet.public_subnet1.id
}
output "ps2id" {
    value = aws_subnet.public_subnet1.id
}