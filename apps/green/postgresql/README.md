# PostgreSQL Setup

## Setup PostgreSQL

```bash
export DIR=apps/green/postgresql
```

1. Create a `Secret` with PostgreSQL details for a user that will be used by Teslamate

```bash
cat <<EOF > $DIR/db-auth-for-teslamate-values.yaml
auth:
  database: teslamate
  username: $POSTGRES_USERNAME
  password: $POSTGRES_PASSWORD
EOF
kubectl create secret generic db-auth-for-teslamate \
  --namespace postgresql \
  --from-file=values.yaml=$DIR/db-auth-for-teslamate-values.yaml \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=$SEALED_SECRET_CERT \
    > $DIR/secret-db-auth-for-teslamate-values.yaml && \
rm -rf $DIR/db-auth-for-teslamate-values.yaml
```
