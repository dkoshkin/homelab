# PostgreSQL Migration: Bitnami to CloudNativePG

Using CloudNativePG's import feature to safely migrate while keeping the existing database running.

## Migration Steps

### Step 1: Deploy Locally

Test the configuration locally before committing to Git:

1. **Validate YAML syntax:**
   ```bash
   kubectl --dry-run=client apply -f postgresql-repository.yaml
   kubectl --dry-run=client apply -f postgresql-release.yaml
   ```

2. **Create the operator:**
   ```bash
   # Apply CloudNativePG operator directly
   kubectl apply -f postgresql-repository.yaml
   kubectl apply -f postgresql-release.yaml
   
   # Wait for operator to be ready
   kubectl wait --for=condition=Available deployment/cloudnative-pg-operator -n postgresql --timeout=300s
   ```

3. **Create cluster:**
   ```bash
   # Apply cluster configuration to test import
   kubectl apply -f cluster.yaml
   
   # Monitor import progress
   kubectl get cluster.postgresql.cnpg.io cnpg-cluster-postgresql -n postgresql -w
   ```

### Step 2: Test the New Cluster

1. **Verify cluster is healthy:**
   ```bash
   ./validate-migration.sh
   ```

### Step 3: Safe Cutover (when confident)

1. **Add Service alias to kustomization:**
   ```bash
   # Create cutover-service.yaml
   kubectl apply -f cutover-service.yaml
   ```

2. **Remove old Bitnami deployment and add Service alias:**
   ```bash
   # Edit kustomization.yaml to remove the old release and add service
   sed -i '/- postgresql-release.yaml/d' kustomization.yaml
   echo "  - cutover-service.yaml" >> kustomization.yaml
   git add kustomization.yaml cutover-service.yaml
   git commit -m "postgresql: cutover from Bitnami to CloudNativePG
   ```

- Remove Bitnami PostgreSQL HelmRelease  
- Add Service alias pointing to CloudNativePG cluster
- Maintains service name 'cluster-postgresql' for zero client impact"
   git push
   
   # Wait for Flux to apply changes
   ```bash
   flux reconcile kustomization apps --with-source
   ```

3. **Verify Teslamate continues working (no config changes needed):**
   ```bash
   kubectl logs -n teslamate deployment/teslamate -f
   kubectl get svc -n postgresql
   ```

### Step 4: Final Cleanup

1. **Remove old PVC if needed:**
   ```bash
   kubectl delete pvc data-cluster-postgresql-0 -n postgresql
   ```

## Service Names

- **Old Bitnami:** `cluster-postgresql.postgresql.svc.cluster.local`
- **New CloudNativePG (direct):** `cnpg-cluster-postgresql-rw.postgresql.svc.cluster.local` (read-write)
- **New CloudNativePG (direct):** `cnpg-cluster-postgresql-ro.postgresql.svc.cluster.local` (read-only)  
- **Service Alias (cutover):** `cluster-postgresql.postgresql.svc.cluster.local` → points to `cnpg-cluster-postgresql-rw`

## Benefits of CloudNativePG

- Not Bitnami, fully open-source
- Better high availability and failover
- Built-in backup and restore
- Monitoring and observability
- Rolling updates without downtime
- Better resource management

