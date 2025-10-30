output "mysql_server_id" {
  description = "The ID of the MySQL server"
  value       = azurerm_mysql_server.main.id
}

output "mysql_server_name" {
  description = "The name of the MySQL server"
  value       = azurerm_mysql_server.main.name
}

output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL server"
  value       = azurerm_mysql_server.main.fqdn
}

output "mysql_database_id" {
  description = "The ID of the MySQL database"
  value       = azurerm_mysql_database.main.id
}

output "mysql_database_name" {
  description = "The name of the MySQL database"
  value       = azurerm_mysql_database.main.name
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.mysql.id
}