output "system_project_id" {
  value = var.enabled ? data.rancher2_project.system[0].id : ""
}

output "token_key" {
  value = var.enabled && length(rancher2_token.this) > 0 ? rancher2_token.this[0].token : ""
}

output "api_url" {
  value = "https://${var.rancher_hostname}"
}
