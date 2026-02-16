# Lovenotes Setup

## Setup Auth

```bash
export DIR=apps/green/lovenotes
```

1. Create a `Secret` with basic auth credentials

```bash
cat <<EOF > $DIR/db-auth-for-teslamate-values.yaml
auth:
  username: $LOVENOTES_USER
  password: $LOVENOTES_PASSWORD
EOF
kubectl create secret generic lovenotes-admin-auth \
  --namespace lovenotes \
  --from-file=values.yaml=$DIR/db-auth-for-teslamate-values.yaml \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=$SEALED_SECRET_CERT \
    > $DIR/secret-lovenotes-admin-auth.yaml && \
rm -rf $DIR/db-auth-for-teslamate-values.yaml
```
