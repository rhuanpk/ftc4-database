output "endpoint_product" {
  description = "Endpoint da instância RDS - Produtos: "
  value       = aws_db_instance.product.endpoint
}
output "endpoint_order" {
  description = "Endpoint da instância RDS - Pedidos: "
  value       = aws_db_instance.order_db.endpoint
}
output "endpoint_payment" {
  description = "Endpoint da instância RDS - Pagamentos: "
  value       = aws_db_instance.payment.endpoint
}

output "connection_strings" {
  value = mongodbatlas_cluster.my_cluster.connection_strings.0.standard_srv
}
