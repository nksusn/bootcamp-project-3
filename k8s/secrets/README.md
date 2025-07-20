# External Secrets Configuration

## Issues Found and Solutions

### 1. API Version Mismatch
The error message indicates that the CRD for ExternalSecret in version `v1beta1` is not being recognized correctly, despite the CRDs being installed. This could be due to:

- The External Secrets Operator version installed might be using a different API version
- The CRDs might not be fully registered yet

**Solution:**
- Try using the v1 API version files: `externalsecret-app-v1.yaml` and `externalsecret-db-v1.yaml`
- If that doesn't work, check the installed version with: `helm list -n external-secrets`
- You might need to reinstall the External Secrets Operator with: 
  ```
  helm upgrade --install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
  ```

### 2. Namespace and ServiceAccount Issues
The original configuration had namespace mismatches between the SecretStore and ExternalSecrets.

**Solution:**
- Use the ClusterSecretStore approach which works across namespaces
- Apply the files in this order:
  1. `serviceaccount.yaml` (update the role ARN first)
  2. `clustersecretstore-v1.yaml` or `clustersecretstore.yaml`
  3. `externalsecret-app-v1.yaml` or `externalsecret-app.yaml`
  4. `externalsecret-db-v1.yaml` or `externalsecret-db.yaml`

### 3. IRSA Configuration
Make sure the IAM role used has the correct permissions and trust relationship.

**Solution:**
- Verify the IAM role ARN in the ServiceAccount annotation
- Check that the role has the necessary permissions for AWS Secrets Manager
- Ensure the trust relationship allows the EKS OIDC provider to assume the role

## Debugging Steps

If issues persist:

1. Check the External Secrets Operator logs:
   ```
   kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets
   ```

2. Verify the ServiceAccount has the correct annotations:
   ```
   kubectl get sa external-secrets -n external-secrets -o yaml
   ```

3. Test AWS credentials with:
   ```
   kubectl create job --from=cronjob/aws-test aws-test-manual
   kubectl logs job/aws-test-manual
   ```

4. Check if the secrets exist in AWS Secrets Manager:
   ```
   aws secretsmanager list-secrets --region us-east-2
   ```