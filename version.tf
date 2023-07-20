terraform {
  required_version = "~> 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.21.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}