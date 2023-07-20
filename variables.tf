variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^\\w{2}-\\w+-\\d+$", var.aws_region))
    error_message = "The AWS region should be in the format 'xx-xxxx-x'."
  }
}

variable "kubernetes_version" {
  description = "Version of Kubernetes"
  type        = string
  default     = "1.27"

  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "The Kubernetes version should be in the format 'x.x'."
  }
}

variable "public_access" {
  description = "Indicates if public access to cluster is allowed"
  type        = bool
  default     = true
}

variable "private_access" {
  description = "Indicates if private access to cluster is allowed (if public is false and private true then, the cluster only can be reached from local VPC or VPN)"
  type        = bool
  default     = false
}

variable "kube_prometheus_stack" {
  description = "Prometheus stack for k8s https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack"
  type        = bool
  default     = false
}

variable "cert_manager" {
  description = "Managing certs in k8s cluster"
  type        = bool
  default     = false
}

variable "secrets_store_csi_driver" {
  description = "Manages secrets on AWS services such as SSM parameter store or Secrets Manager"
  type        = bool
  default     = false
}

variable "metrics_server" {
  description = "Enable Metric_server for k8s cluster."
  type        = bool
  default     = false
}

variable "cloudwatch_metrics" {
  description = "Enable AWS Cloudwatch Metrics. metric_server must be true."
  type        = bool
  default     = false
}

variable "efs_csi" {
  description = "Enable Amazon EFS CSI Driver"
  type        = bool
  default     = false
}

variable "api_gw_controller" {
  description = "Enable AWS API Gatway controller."
  type        = bool
  default     = false
}

variable "velero" {
  description = "Enable Velero config backup solution."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-0b4b721474fc3a76f", "subnet-00970d29b55ff36a8"]

  validation {
    condition     = can(length(var.subnet_ids) > 0)
    error_message = "At least one subnet ID should be provided."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = list(string)
  default     = ["t3.small", "t3.medium"]

  validation {
    condition     = can(length(var.instance_type) > 0)
    error_message = "Invalid EC2 instance type format."
  }
}

variable "min_size" {
  description = "Minimun instances running for managed node group"
  type        = number
  default     = 2

  validation {
    condition     = can(var.min_size >= 1 && var.min_size <= 100)
    error_message = "Size must be in number between 1 and 100."
  }
}

variable "max_size" {
  description = "Max instances running for managed node group"
  type        = number
  default     = 4

  validation {
    condition     = can(var.max_size >= 1 && var.max_size <= 100)
    error_message = "Size must be in number between 1 and 100 and greater than min_size variable"
  }
}

variable "desired_size" {
  description = "Desired instances running at the same time for managed node group"
  type        = number
  default     = 2

  validation {
    condition     = can(var.desired_size >= 1 && var.desired_size <= 100)
    error_message = "Size must be in number between 1 and 100 and >= than min_size variable and less than max_size variable"
  }
}

variable "disk_size" {
  description = "EC2 disk size"
  type        = number
  default     = 30

  validation {
    condition     = can(var.disk_size >= 8 && var.disk_size <= 64000)
    error_message = "Size must be in number between 8 and 64000 (GB)."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = "arn:aws:kms:us-east-1:123456789012:key/e589fe53-4af7-b084-dad1-331b80f17860"

  validation {
    condition     = var.kms_key_arn == "" || can(regex("^arn:aws:kms:.*", var.kms_key_arn))
    error_message = "Invalid KMS key ARN. Please provide a valid ARN or leave it empty."
  }
}

variable "allowed_ip_addresses" {
  description = "Comma-separated list of allowed IP addresses (CIDR notation) for security group ingress"
  type        = string
  default     = "192.168.10.0/24,192.168.11.0/24"

  validation {
    condition     = can(regex("^(((\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2})|(,|$))+$", var.allowed_ip_addresses))
    error_message = "The allowed_ip_addresses variable must be either a single IP address in CIDR notation or a comma-separated list of IP addresses in CIDR notation."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-project"

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]+$", var.project_name))
    error_message = "The project_name variable must only contain alphanumeric characters, underscores, and hyphens."
  }
}

variable "admin_role_arns" {
  description = "ARNs of the admin roles separated by commas"
  type        = string
  default     = "arn:aws:iam::123456789012:role/ROLENAME1,arn:aws:iam::123456789012:role/ROLENAME2"

  validation {
    condition     = can(regex("^(arn:aws:iam::[0-9]+:role/[^,]+(,|$))+$", var.admin_role_arns))
    error_message = "The admin_role_arns variable must be either a single ARN or a comma-separated list of ARNs."
  }
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = "vpc-12345678"

  validation {
    condition     = can(regex("^vpc-[a-zA-Z0-9]+$", var.vpc_id))
    error_message = "Invalid VPC ID format. Please provide a valid VPC ID."
  }
}

variable "alb_controller_version" {
  description = "ALB controller version, for more info -> https://github.com/kubernetes-sigs/aws-load-balancer-controller"
  type        = string
  default     = "v2.5.3"

  validation {
    condition     = can(regex("^v\\d+\\.\\d+\\.\\d+$", var.alb_controller_version))
    error_message = "The ALB controller version should be in the format 'vx.x.x'."
  }
}

variable "albc_helm_chart_version" {
  description = "Version of the ALB controller Helm chart, for more info -> https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller"
  type        = string
  default     = "1.5.4"

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.albc_helm_chart_version))
    error_message = "The ALB controller version should be in the format 'x.x.x'."
  }
}

variable "karpenter_helm_chart_version" {
  description = "Version of the ALB controller Helm chart, for more info -> https://artifacthub.io/packages/helm/karpenter/karpenter"
  type        = string
  default     = "0.16.3"

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.karpenter_helm_chart_version))
    error_message = "The ALB controller version should be in the format 'x.x.x'."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to AWS resources"
  default = {
    Environment = "Development"
    Owner       = "Frankin Garcia"
  }
}

# Schedules
variable "enable_schedules" {
  description = "Enable schedules to scale down and scale up at days and hours"
  type        = bool
  default     = true
}

variable "tz" {
  type        = string
  default     = "Etc/GMT-4"
  description = "Timezone for shedules"

  validation {
    condition     = can(regex("^((Etc/GMT[+-]\\d+)|([A-Za-z_]+/[A-Za-z_]+))$", var.tz)) || can(regex("^[A-Za-z_]+/[A-Za-z_]+$", var.tz))
    error_message = "The timezone variable must be in the format 'Continent/City' or 'Etc/GMT-X', e.g., 'America/New_York' or 'Etc/GMT-4'."
  }
}

variable "start_time" {
  type        = string
  description = "The start time of the schedule."
  default     = "2023-03-05T00:00:00Z"
  validation {
    condition     = can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", var.start_time))
    error_message = "Format iso8601 YYYY-MM-DDT00:00:00Z. i.e: 2023-03-05T00:00:00Z"
  }
}

variable "scale_up_recurrence" {
  type        = string
  default     = "0 8 * * *"
  description = "The recurrence of the schedule. The format is 0 8 * * *, which means every day at 8:00 AM."

  validation {
    condition     = can(regex("^(([0-9*-/]+(,[0-9*-/]+)*)\\s+){4}[0-9*-/]+$", var.scale_up_recurrence))
    error_message = "The recurrence must be in the format 0 8 * * *."
  }
}

variable "scale_down_recurrence" {
  type        = string
  default     = "0 20 * * *"
  description = "The recurrence of the schedule. The format is 0 20 * * *, which means every day at 20:00 (PM)."

  validation {
    condition     = can(regex("^(([0-9*-/]+(,[0-9*-/]+)*)\\s+){4}[0-9*-/]+$", var.scale_down_recurrence))
    error_message = "The recurrence must be in the format 0 20 * * *."
  }
}