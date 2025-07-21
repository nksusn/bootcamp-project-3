#!/bin/bash

# Create IAM policy for External Secrets
aws iam create-policy \
  --policy-name ExternalSecretsPolicy \
  --policy-document file://external-secrets-policy.json \
  --region us-east-2

# Get OIDC provider URL for the EKS cluster
OIDC_PROVIDER=$(aws eks describe-cluster --name eks-nebulance --region us-east-2 --query "cluster.identity.oidc.issuer" --output text | sed 's|https://||')

# Create trust relationship JSON file
cat > trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::940482433884:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:default:external-secrets-sa"
        }
      }
    }
  ]
}
EOF

# Create IAM role with trust relationship
aws iam create-role \
  --role-name eks-app-eso-irsa-role \
  --assume-role-policy-document file://trust-relationship.json \
  --region us-east-2

# Attach policy to role
aws iam attach-role-policy \
  --role-name eks-app-eso-irsa-role \
  --policy-arn arn:aws:iam::940482433884:policy/ExternalSecretsPolicy \
  --region us-east-2