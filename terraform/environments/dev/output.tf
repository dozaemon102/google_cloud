output "workload_identity_provider" {
  value = module.github_actions.workload_identity_provider
}
output "deployer_service_account" {
  value = module.github_actions.deployer_service_account
}