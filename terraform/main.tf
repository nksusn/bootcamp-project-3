terraform {
  required_version = ">= 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#############################
# VPC Module
#############################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = var.cluster_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = {
    Project = var.cluster_name
  }
}

#############################
# EKS Module
#############################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  enable_irsa = true

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  kms_key_enable_default_policy = true
  create_kms_key                = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.min_size
    }
  }

  tags = {
    Project = var.cluster_name
  }
}

#############################
# IAM Policy for IRSA (External Secrets)
#############################

data "aws_iam_policy_document" "irsa_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_arn, \":oidc-provider/\", \":sub\")}"
      values   = ["system:serviceaccount:kube-system:external-secrets"]
    }
  }
}

resource "aws_iam_policy" "external_secrets_policy" {
  name        = "ExternalSecretsPolicy"
  description = "Permissions for External Secrets Operator"

  policy = file("external-secrets-policy.json")
}

resource "aws_iam_role" "external_secrets_irsa" {
  name               = "external-secrets-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_policy.json

  tags = {
    Project = var.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets_attachment" {
  role       = aws_iam_role.external_secrets_irsa.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}
