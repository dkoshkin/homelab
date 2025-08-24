#!/bin/bash

# CloudNativePG Migration Validation Script
set -e

NAMESPACE="postgresql"
OLD_CLUSTER="cluster-postgresql"
NEW_CLUSTER="cnpg-cluster-postgresql"

echo "🔍 CloudNativePG Migration Validation"
echo "====================================="

# Check if CloudNativePG operator is running
echo "1. Checking CloudNativePG operator..."
if kubectl get deployment cloudnative-pg-operator -n $NAMESPACE >/dev/null 2>&1; then
    STATUS=$(kubectl get deployment cloudnative-pg-operator -n $NAMESPACE -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')
    if [ "$STATUS" = "True" ]; then
        echo "   ✅ CloudNativePG operator is running"
    else
        echo "   ❌ CloudNativePG operator is not ready"
        exit 1
    fi
else
    echo "   ❌ CloudNativePG operator not found"
    exit 1
fi

# Check if new cluster is ready
echo "2. Checking new CloudNativePG cluster..."
if kubectl get cluster.postgresql.cnpg.io $NEW_CLUSTER -n $NAMESPACE >/dev/null 2>&1; then
    STATUS=$(kubectl get cluster.postgresql.cnpg.io $NEW_CLUSTER -n $NAMESPACE -o jsonpath='{.status.phase}')
    if [ "$STATUS" = "Cluster in healthy state" ]; then
        echo "   ✅ CloudNativePG cluster is healthy"
    else
        echo "   ⏳ CloudNativePG cluster status: $STATUS"
        echo "   📋 Check logs: kubectl logs -n $NAMESPACE ${NEW_CLUSTER}-1 -f"
        exit 1
    fi
else
    echo "   ❌ CloudNativePG cluster not found"
    exit 1
fi

# Check if teslamate database exists
echo "3. Checking teslamate database..."
DB_EXISTS=$(kubectl exec -n $NAMESPACE ${NEW_CLUSTER}-1 -- psql -U postgres -lqt | cut -d \| -f 1 | grep -w teslamate | wc -l)
if [ "$DB_EXISTS" -gt 0 ]; then
    echo "   ✅ teslamate database exists"
else
    echo "   ❌ teslamate database not found"
    exit 1
fi

# Check table count
echo "4. Checking data migration..."
TABLE_COUNT=$(kubectl exec -n $NAMESPACE ${NEW_CLUSTER}-1 -- psql -U postgres -d teslamate -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" -t | tr -d ' ')
if [ "$TABLE_COUNT" -gt 10 ]; then
    echo "   ✅ Found $TABLE_COUNT tables in teslamate database"
else
    echo "   ⚠️  Only found $TABLE_COUNT tables (expected more)"
fi

# Check services
echo "5. Checking services..."
if kubectl get svc ${NEW_CLUSTER}-rw -n $NAMESPACE >/dev/null 2>&1; then
    echo "   ✅ Read-write service exists: ${NEW_CLUSTER}-rw"
else
    echo "   ❌ Read-write service not found"
    exit 1
fi

if kubectl get svc ${NEW_CLUSTER}-ro -n $NAMESPACE >/dev/null 2>&1; then
    echo "   ✅ Read-only service exists: ${NEW_CLUSTER}-ro"
else
    echo "   ⚠️  Read-only service not found (this is normal for single instance)"
fi

echo ""
echo "🎉 Migration validation completed successfully!"
echo ""
