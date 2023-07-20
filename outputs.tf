output "cluster_name" {
  value = module.eks.cluster_id
}

output "worker_node_role" {
  value = aws_iam_role.eks_worker.arn
}

output "worker_sg" {
  value = aws_security_group.eks_sg.id
}

output "eks_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca_base64" {
  value = base64decode(module.eks.cluster_certificate_authority_data)
}