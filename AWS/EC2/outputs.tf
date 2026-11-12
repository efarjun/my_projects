output "web_server" {
  description = "Web server instance details"
  value = {
    instance_id       = module.web_server.instance_id
    private_ip        = module.web_server.private_ip
    security_group_id = module.web_server_sg.id
  }
}

output "batch_server" {
  description = "Batch server instance details"
  value = {
    instance_id       = module.batch_server.instance_id
    private_ip        = module.batch_server.private_ip
    security_group_id = module.batch_server_sg.id
  }
}

