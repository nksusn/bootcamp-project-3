# Setting up IRSA for External Secrets

The error in the logs shows:
```
unable to create session: an IAM role must be associated with service account external-secrets (namespace: external-secrets)
```

This means the ServiceAccount doesn't have a proper IAM role associated with it. Follow these steps to fix it:

## 1. Create an IAM OIDC Provider for your EKS cluster

If you haven't already created an OIDC provider for your cluster, run:

```bash
eksctl utils associate-iam-oidc-provider --cluster eks-nebulance --approve --region us-east-2
```

## 2. Create an IAM Role for External Secrets

Create an IAM role with the necessary permissions and trust relationship:

```bash
# Get your AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create the IAM policy
aws iam create-policy \
  --policy-name ExternalSecretsPolicy \
  --policy-document file://terraform/external-secrets-policy.json \
  --region us-east-2

# Create the IAM role with IRSA
eksctl create iamserviceaccount \
  --name external-secrets \
  --namespace external-secrets \
  --cluster eks-nebulance \
  --attach-policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/ExternalSecretsPolicy \
  --approve \
  --region us-east-2
```

## 3. Update the ServiceAccount

If you created the ServiceAccount manually, update it with the correct role ARN:

```bash
kubectl apply -f k8s/secrets/serviceaccount-fixed.yaml
```

Make sure to replace `<AWS_ACCOUNT_ID>` in the serviceaccount-fixed.yaml file with your actual AWS account ID.

## 4. Apply the ClusterSecretStore and ExternalSecrets

```bash
kubectl apply -f k8s/secrets/clustersecretstore-v1.yaml
kubectl apply -f k8s/secrets/externalsecret-app-v1.yaml
kubectl apply -f k8s/secrets/externalsecret-db-v1.yaml
```

## 5. Verify the setup

```bash
# Check if the ServiceAccount has the correct annotation
kubectl get sa external-secrets -n external-secrets -o yaml

# Check the status of the ClusterSecretStore
kubectl get clustersecretstore eks-app-clustersecretstore -o yaml

# Check if the ExternalSecrets are syncing
kubectl get externalsecrets -n default
```