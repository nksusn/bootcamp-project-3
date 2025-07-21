# External Secrets Setup

## 1. Create IAM Role and Policy

Run the script to create the IAM role and policy:

```bash
cd k8s
chmod +x create-iam-role.sh
./create-iam-role.sh
```

## 2. Create AWS Secret

Run the script to create the AWS secret:

```bash
chmod +x create-aws-secret.sh
./create-aws-secret.sh
```

## 3. Apply Kubernetes Resources

Apply the ServiceAccount, ClusterSecretStore, and ExternalSecret:

```bash
kubectl apply -f service-account.yaml
kubectl apply -f cluster-secret-store.yaml
kubectl apply -f frontend-external-secret.yaml
```

## 4. Verify

Check if the secret was created:

```bash
kubectl get secrets app-secrets -n default
```

## Troubleshooting

If you encounter issues:

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