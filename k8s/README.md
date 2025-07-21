# External Secrets Setup

## API Version Issue Fixed

The issue was that you were using `apiVersion: external-secrets.io/v1beta1` but the installed CRDs are using `v1`. I've updated the files to use the correct API version.

## Steps to Apply

1. Update the AWS account ID in the service-account.yaml file:
   ```bash
   # Get your AWS account ID
   AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
   
   # Replace <AWS_ACCOUNT_ID> with your actual AWS account ID
   sed -i "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g" k8s/service-account.yaml
   ```

2. Apply the ServiceAccount:
   ```bash
   kubectl apply -f k8s/service-account.yaml
   ```

3. Apply the ClusterSecretStore:
   ```bash
   kubectl apply -f k8s/cluster-secret-store.yaml
   ```

4. Apply the ExternalSecret:
   ```bash
   kubectl apply -f k8s/frontend-external-secret.yaml
   ```

5. Check if the secret was created:
   ```bash
   kubectl get secrets app-secrets -n default
   ```

## Troubleshooting

If you still have issues:

1. Check the External Secrets Operator logs:
   ```bash
   kubectl logs -n external-secrets deploy/external-secrets
   ```

2. Check the status of the ClusterSecretStore:
   ```bash
   kubectl get clustersecretstore aws-secretsmanager -o yaml
   ```

3. Check the status of the ExternalSecret:
   ```bash
   kubectl get externalsecret app-secrets -n default -o yaml
   ```

4. Make sure the AWS secret exists:
   ```bash
   aws secretsmanager describe-secret --secret-id app/secrets --region us-east-2
   ```

5. If the secret doesn't exist, create it:
   ```bash
   aws secretsmanager create-secret \
     --name app/secrets \
     --secret-string '{"key1":"value1","key2":"value2"}' \
     --region us-east-2
   ```