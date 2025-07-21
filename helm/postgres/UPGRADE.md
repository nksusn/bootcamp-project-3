# PostgreSQL Helm Chart Upgrade

## Changes Made

1. Switched from Deployment to StatefulSet
   - StatefulSets are more appropriate for databases
   - They provide stable network identities and persistent storage

2. Explicitly set storage class to "gp2"
   - This matches the default storage class in your cluster
   - The storage class uses WaitForFirstConsumer binding mode

3. Added subPath to volume mount
   - Prevents PostgreSQL initialization issues with empty directories

## How to Upgrade

1. Uninstall the current release:
   ```bash
   helm uninstall postgres
   ```

2. Delete any stuck PVCs:
   ```bash
   kubectl delete pvc --all
   ```

3. Install the updated chart:
   ```bash
   helm install postgres ./postgres
   ```

4. Check the status:
   ```bash
   kubectl get pods -l app=postgres
   kubectl get pvc
   ```

5. Wait for the pod to start (it may take a minute):
   ```bash
   kubectl get pods -l app=postgres -w
   ```

## Troubleshooting

If the pod is still stuck in Pending state:

1. Check events:
   ```bash
   kubectl get events | grep postgres
   ```

2. Check pod details:
   ```bash
   kubectl describe pod -l app=postgres
   ```

3. Check PVC details:
   ```bash
   kubectl get pvc
   kubectl describe pvc
   ```