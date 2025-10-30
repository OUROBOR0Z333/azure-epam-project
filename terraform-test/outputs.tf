output "test_resource_group_name" {
  description = "Name of the test resource group created"
  value       = azurerm_resource_group.test[0].name
  depends_on  = [azurerm_resource_group.test]
}