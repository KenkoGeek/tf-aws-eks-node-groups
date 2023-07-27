# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state-bucket"
#     key    = "my-terraform-state-key"
#     region = var.aws_region
#     # dynamodb_table = "my-terraform-state-lock"
#   }
# }

# KMS for secrets and logs
resource "aws_kms_key" "logs_cmk" {
  description             = "KMS key for k8s secrets and logs"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = true
  tags                    = var.tags
  policy                  = data.aws_iam_policy_document.k8s_secrets_logs_kms_policy.json
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.project_name}-cluster"
  target_key_id = aws_kms_key.logs_cmk.arn
}

resource "aws_ebs_encryption_by_default" "enabled" {
  enabled = true
}

# ALB controller policy
resource "aws_iam_policy" "alb_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.lbc_iam_policy.response_body
  tags   = var.tags
}

# Extra SG
resource "aws_security_group" "eks_sg" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for ${var.project_name} EKS cluster/nodes"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags, {
      Name                     = "${var.project_name}-eks-cluster-sg",
      "karpenter.sh/discovery" = "${var.project_name}-cluster"
    }
  )

  ingress {
    description = "Allow incoming connections"
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = split(",", var.allowed_ip_addresses)
  }

  ingress {
    description = "Allow incoming connections from local VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }
}

# EKS Cluster
resource "aws_iam_role" "eks_worker" {
  name = "${var.project_name}-eks-workper-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2EKSWorker"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "alb_controller" {
  name       = "alb-controller-attachment"
  roles      = [aws_iam_role.eks_worker.name]
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

resource "aws_iam_policy_attachment" "vpc_cni" {
  name       = "vpc-cni-attachment"
  roles      = [aws_iam_role.eks_worker.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy_attachment" "ecr_ro" {
  name       = "ecr-ro-attachment"
  roles      = [aws_iam_role.eks_worker.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy_attachment" "eks_worker" {
  name       = "eks-worker-attachment"
  roles      = [aws_iam_role.eks_worker.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_policy_attachment" "ssm" {
  name       = "ssm-attachment"
  roles      = [aws_iam_role.eks_worker.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.24.0"

  map_roles = concat(
    [
      {
        rolearn  = aws_iam_role.eks_worker.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ],
    [
      for role_arn in split(",", var.admin_role_arns) :
      {
        rolearn  = role_arn
        username = "{{SessionName}}"
        groups   = ["system:masters"]
      }
    ]
  )
  cluster_version                 = var.kubernetes_version
  cluster_name                    = "${var.project_name}-cluster"
  vpc_id                          = var.vpc_id
  subnets                         = var.subnet_ids
  cluster_endpoint_private_access = var.private_access
  cluster_endpoint_public_access  = var.public_access #tfsec:ignore:aws-eks-no-public-cluster-access
  enable_irsa                     = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  cluster_log_kms_key_id        = aws_kms_key.logs_cmk.arn
  cluster_log_retention_in_days = 90

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.logs_cmk.arn
      resources        = ["secrets"]

    }
  ]
  cluster_tags = var.tags
}

resource "aws_security_group_rule" "worker_sg" {
  type                     = "ingress"
  description              = "Allow incoming connections worker extra SG"
  from_port                = 0 - 65536
  to_port                  = 0 - 65536
  protocol                 = "all"
  source_security_group_id = aws_security_group.eks_sg.id
  security_group_id        = module.eks.cluster_primary_security_group_id
}

# EKS Manage node group
module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~> 19.15.3"

  name                              = "${var.project_name}-eks-worker"
  cluster_name                      = module.eks.cluster_id
  cluster_endpoint                  = module.eks.cluster_endpoint
  cluster_version                   = var.kubernetes_version
  subnet_ids                        = var.subnet_ids
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.cluster_security_group_id, aws_security_group.eks_sg.id]
  min_size                          = var.min_size
  max_size                          = var.max_size
  desired_size                      = var.desired_size
  instance_types                    = var.instance_type
  force_update_version              = true
  tags                              = var.tags

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = var.disk_size
        volume_type           = "gp3"
        iops                  = 3000
        throughput            = 150
        encrypted             = true
        kms_key_id            = data.aws_ebs_default_kms_key.current.key_arn
        delete_on_termination = true
      }
    }
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  create_iam_role = false
  iam_role_arn    = aws_iam_role.eks_worker.arn

  # To stop and start instances at fixed hours and days
  create_schedule = var.enable_schedules

  schedules = var.enable_schedules ? {
    scale-up = {
      min_size     = var.min_size
      max_size     = "-1"
      desired_size = var.desired_size
      start_time   = var.start_time
      # end_time     = "2024-03-05T00:00:00Z"
      timezone   = var.tz
      recurrence = var.scale_up_recurrence
    },
    scale-down = {
      min_size     = 0
      max_size     = "-1"
      desired_size = 0
      start_time   = var.start_time
      # end_time     = "2024-03-05T12:00:00Z"
      timezone   = var.tz
      recurrence = var.scale_down_recurrence
    }
  } : {}
}


# EKS Addons, to check the latest version please read https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html
module "eks_blueprints_addons" {
  depends_on = [module.eks_managed_node_group]
  source     = "aws-ia/eks-blueprints-addons/aws"
  version    = "~> 1.2.2"

  cluster_name      = module.eks.cluster_id
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller          = true
  enable_cluster_proportional_autoscaler       = false
  enable_kube_prometheus_stack                 = var.kube_prometheus_stack
  enable_metrics_server                        = var.metrics_server
  enable_cert_manager                          = var.cert_manager
  enable_aws_cloudwatch_metrics                = var.cloudwatch_metrics
  enable_external_secrets                      = false
  enable_secrets_store_csi_driver_provider_aws = var.secrets_store_csi_driver
  enable_velero                                = var.velero
  enable_aws_efs_csi_driver                    = var.velero
  enable_aws_gateway_api_controller            = var.api_gw_controller
  tags                                         = var.tags
}

# Karpenter
resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile"
  role = aws_iam_role.eks_worker.name
}

module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.27.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${var.project_name}"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}

resource "aws_iam_role_policy" "karpenter_controller" {
  name   = "karpenter-policy-${var.project_name}"
  role   = module.iam_assumable_role_karpenter.iam_role_name
  policy = data.aws_iam_policy_document.karpenter_policy.json
}

resource "helm_release" "karpenter" {
  depends_on = [module.eks_managed_node_group, aws_iam_role_policy.karpenter_controller]

  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter"
  repository       = "https://charts.karpenter.sh"
  chart            = "karpenter"
  version          = var.karpenter_helm_chart_version
  force_update     = true

  set {
    name  = "clusterName"
    value = "${var.project_name}-cluster"
  }

  set {
    name  = "clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "serviceAccount.name"
    value = "karpenter"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  depends_on = [helm_release.karpenter]

  yaml_body = <<-EOF
    apiVersion: "karpenter.sh/v1alpha5"
    kind: "Provisioner"
    metadata:
      name: "karpenter"
    spec:
      requirements:
       - key: "node.kubernetes.io/instance-type"
         operator: In
         values: [${join(", ", var.instance_type)}]
       - key: "karpenter.k8s.aws/instance-hypervisor"
         operator: In
         values: [ "nitro" ]
      limits:
        resources:
          cpu: 1000
          memory: 1000Gi
      provider:
        tags:
          Name: "${var.project_name}-eks-additional-worker"
        subnetSelector:
          karpenter.sh/discovery: "${module.eks.cluster_id}"
        securityGroupSelector:
          aws-ids: "${aws_security_group.eks_sg.id}"
        blockDeviceMappings:
          - deviceName: "/dev/xvda"
            ebs:
              volumeSize: "${var.disk_size}Gi"
              volumeType: "gp3"
              deleteOnTermination: true
      ttlSecondsAfterEmpty: 30
      ttlSecondsUntilExpired: 2592000
  EOF
}
