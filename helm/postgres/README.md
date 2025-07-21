# PostgreSQL Helm Chart

## PVC Issue Resolution

If your PVCs are stuck in "Pending" state, it could be due to one of the following reasons:

1. **Storage Class Issue**: The specified storage class doesn't exist or isn't available
   - Solution: Update `values.yaml` to use an available storage class or leave it empty to use the default

2. **No Default Storage Class**: Your cluster might not have a default storage class
   - Solution: Create a storage class or specify an existing one

3. **Resource Quota**: Your cluster might have resource quotas that prevent PVC creation
   - Solution: Check resource quotas and adjust as needed

## Quick Fix

To fix the PVC issue:

1. Check available storage classes:
   ```bash
   kubectl get storageclass
   ```

2. Update the `values.yaml` file with an available storage class:
   ```yaml
   persistence:
     enabled: true
     accessModes:
       - ReadWriteOnce
     size: 5Gi
     storageClass: "gp2" # Use an available storage class
   ```

3. Uninstall and reinstall the chart:
   ```bash
   helm uninstall postgres
   helm install postgres ./postgres
   ```

## Debugging

If issues persist:

1. Check PVC status:
   ```bash
   kubectl get pvc
   kubectl describe pvc postgres-postgres-pvc
   ```

2. Check events:
   ```bash
   kubectl get events | grep pvc
   ```

3. Check if the storage class exists:
   ```bash
   kubectl get storageclass
   ```