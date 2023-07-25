

# Preparing the environment

1. Clone the repository using `git`
```bash
git clone the-repository/project
```
2. Change to the project directory
```bash
cd project/
```
3. Init the Terraform project
```bash
terraform init
```
4. Validate the configurations files
```bash
terraform validate
```
5. Lint the project

Installation guide for tflint -> https://github.com/terraform-linters/tflint
```bash
tflint
```
6. Validate for security best practices

Installation guide for tfsec -> https://aquasecurity.github.io/tfsec/v1.28.1/guides/installation/
```bash
tfsec
```
7. Give some format (just in case)
```bash
terraform fmt
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.3.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.10.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 2.4.1 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.10.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.4.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.21.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 17.24.0 |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | ~> 1.2.2 |
| <a name="module_eks_managed_node_group"></a> [eks\_managed\_node\_group](#module\_eks\_managed\_node\_group) | terraform-aws-modules/eks/aws//modules/eks-managed-node-group | ~> 19.15.3 |
| <a name="module_iam_assumable_role_karpenter"></a> [iam\_assumable\_role\_karpenter](#module\_iam\_assumable\_role\_karpenter) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.27.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_encryption_by_default.enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_ec2_tag.eks_cluster_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_tag.internal_alb_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_tag.karpenter_discovery_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_iam_instance_profile.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.alb_controller_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.alb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.ecr_ro](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.karpenter_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.logs_cmk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.eks_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.karpenter_provisioner](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ebs_default_kms_key.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ebs_default_kms_key) | data source |
| [aws_iam_policy_document.k8s_secrets_logs_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.karpenter_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [http_http.lbc_iam_policy](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_role_arns"></a> [admin\_role\_arns](#input\_admin\_role\_arns) | ARNs of the admin roles separated by commas | `string` | `"arn:aws:iam::123456789012:role/ROLENAME1,arn:aws:iam::123456789012:role/ROLENAME2"` | no |
| <a name="input_alb_controller_version"></a> [alb\_controller\_version](#input\_alb\_controller\_version) | ALB controller version, for more info -> https://github.com/kubernetes-sigs/aws-load-balancer-controller | `string` | `"v2.5.3"` | no |
| <a name="input_albc_helm_chart_version"></a> [albc\_helm\_chart\_version](#input\_albc\_helm\_chart\_version) | Version of the ALB controller Helm chart, for more info -> https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller | `string` | `"1.5.4"` | no |
| <a name="input_allowed_ip_addresses"></a> [allowed\_ip\_addresses](#input\_allowed\_ip\_addresses) | Comma-separated list of allowed IP addresses (CIDR notation) for security group ingress | `string` | `"192.168.10.0/24,192.168.11.0/24"` | no |
| <a name="input_api_gw_controller"></a> [api\_gw\_controller](#input\_api\_gw\_controller) | Enable AWS API Gatway controller. | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_cert_manager"></a> [cert\_manager](#input\_cert\_manager) | Managing certs in k8s cluster | `bool` | `false` | no |
| <a name="input_cloudwatch_metrics"></a> [cloudwatch\_metrics](#input\_cloudwatch\_metrics) | Enable AWS Cloudwatch Metrics. metric\_server must be true. | `bool` | `false` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Desired instances running at the same time for managed node group | `number` | `2` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | EC2 disk size | `number` | `30` | no |
| <a name="input_enable_schedules"></a> [enable\_schedules](#input\_enable\_schedules) | Enable schedules to scale down and scale up at days and hours | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `list(string)` | <pre>[<br>  "t3.small",<br>  "t3.medium"<br>]</pre> | no |
| <a name="input_karpenter_helm_chart_version"></a> [karpenter\_helm\_chart\_version](#input\_karpenter\_helm\_chart\_version) | Version of the ALB controller Helm chart, for more info -> https://artifacthub.io/packages/helm/karpenter/karpenter | `string` | `"0.16.3"` | no |
| <a name="input_kube_prometheus_stack"></a> [kube\_prometheus\_stack](#input\_kube\_prometheus\_stack) | Prometheus stack for k8s https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version of Kubernetes | `string` | `"1.27"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Max instances running for managed node group | `number` | `4` | no |
| <a name="input_metrics_server"></a> [metrics\_server](#input\_metrics\_server) | Enable Metric\_server for k8s cluster. | `bool` | `false` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimun instances running for managed node group | `number` | `2` | no |
| <a name="input_private_access"></a> [private\_access](#input\_private\_access) | Indicates if private access to cluster is allowed (if public is false and private true then, the cluster only can be reached from local VPC or VPN) | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"my-project"` | no |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | Indicates if public access to cluster is allowed | `bool` | `true` | no |
| <a name="input_scale_down_recurrence"></a> [scale\_down\_recurrence](#input\_scale\_down\_recurrence) | The recurrence of the schedule. The format is 0 20 * * *, which means every day at 20:00 (PM). | `string` | `"0 20 * * *"` | no |
| <a name="input_scale_up_recurrence"></a> [scale\_up\_recurrence](#input\_scale\_up\_recurrence) | The recurrence of the schedule. The format is 0 8 * * *, which means every day at 8:00 AM. | `string` | `"0 8 * * *"` | no |
| <a name="input_secrets_store_csi_driver"></a> [secrets\_store\_csi\_driver](#input\_secrets\_store\_csi\_driver) | Manages secrets on AWS services such as SSM parameter store or Secrets Manager | `bool` | `false` | no |
| <a name="input_start_time"></a> [start\_time](#input\_start\_time) | The start time of the schedule. | `string` | `"2023-03-05T00:00:00Z"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs | `list(string)` | <pre>[<br>  "subnet-0b4b721474fc3a76f",<br>  "subnet-00970d29b55ff36a8"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources | `map(string)` | <pre>{<br>  "Environment": "Development",<br>  "Owner": "Frankin Garcia"<br>}</pre> | no |
| <a name="input_tz"></a> [tz](#input\_tz) | Timezone for shedules | `string` | `"Etc/GMT-4"` | no |
| <a name="input_velero"></a> [velero](#input\_velero) | Enable Velero config backup solution. | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC | `string` | `"vpc-12345678"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_ca_base64"></a> [eks\_cluster\_ca\_base64](#output\_eks\_cluster\_ca\_base64) | EKS cluster CA in base64 format. |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | EKS cluster endpoint. |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | EKS cluster name. |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | EKS cluster version. |
| <a name="output_eks_oidc_issuer_url"></a> [eks\_oidc\_issuer\_url](#output\_eks\_oidc\_issuer\_url) | EKS cluster OIDC issuer URL. |
| <a name="output_eks_worker_node_role"></a> [eks\_worker\_node\_role](#output\_eks\_worker\_node\_role) | EKS node group role. |
| <a name="output_eks_worker_sg"></a> [eks\_worker\_sg](#output\_eks\_worker\_sg) | EKS node group security group. |


