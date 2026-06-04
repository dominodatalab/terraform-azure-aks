output "dns_zone" {
  description = "DP Azure DNS zone details"
  value       = module.aks.dns_zone
}

output "external_dns_identity" {
  description = "Workload identity for external-dns"
  value       = module.aks.external_dns_identity
}

output "cert_manager_identity" {
  description = "Workload identity for cert-manager"
  value       = module.aks.cert_manager_identity
}
