output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

output "web_subnet_a_id" {
  value = aws_subnet.web_a.id
}

output "app_subnet_a_id" {
  value = aws_subnet.app_a.id
}

output "db_subnet_a_id" {
  value = aws_subnet.db_a.id
}

output "management_subnet_id" {
  value = aws_subnet.management.id
}

output "transit_subnet_a_id" {
  value = aws_subnet.transit_a.id
}

output "transit_subnet_b_id" {
  value = aws_subnet.transit_b.id
}

output "application_route_table_id" {
  value = aws_route_table.application.id
}

output "management_route_table_id" {
  value = aws_route_table.management.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "web_security_group_id" {
  value = aws_security_group.web.id
}

output "application_security_group_id" {
  value = aws_security_group.application.id
}

output "database_security_group_id" {
  value = aws_security_group.database.id
}

output "management_security_group_id" {
  value = aws_security_group.management.id
}
