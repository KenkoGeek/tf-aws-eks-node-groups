output "eks_cluster_name" {
  value       = module.eks.cluster_id
  description = "EKS cluster name."
}

output "eks_oidc_issuer_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "EKS cluster OIDC issuer URL."
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint."
}

output "eks_cluster_ca_base64" {
  value       = base64decode(module.eks.cluster_certificate_authority_data)
  description = "EKS cluster CA in base64 format."
}

output "eks_cluster_version" {
  value       = module.eks.cluster_version
  description = "EKS cluster version."
}

output "eks_worker_node_role" {
  value       = aws_iam_role.eks_worker.arn
  description = "EKS node group role."
}

output "eks_worker_sg" {
  value       = aws_security_group.eks_sg.id
  description = "EKS node group security group."
}

output "eks_worker_core_sg" {
  value       = module.eks_managed_node_group["core"].node_security_group_id
  description = "EKS node group core security group."
}