# PostgreSQL Setup

## Set Environment Variables

1. Fill out the env file

```bash
cd <repo>/clusters/microk8s/
mv .env.sample .env
source .env
```

## Setup PostgreSQL

1. Create a `Secret` with PostgreSQL details for a user that will be used by Teslamate

```bahs
cat <<EOF > db-auth-for-teslamate-values.yaml
auth:
  database: teslamate
  username: $POSTGRES_USERNAME
  password: $POSTGRES_PASSWORD
EOF
kubectl create secret generic db-auth-for-teslamate \
  --namespace teslamate \
  --from-file=values.yaml=db-auth-for-teslamate-values.yaml \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=../../../clusters/microk8s/pub-sealed-secrets.pem \
    > secret-db-auth-for-teslamate-values.yaml && \
rm -rf db-auth-for-teslamate-values.yaml
```
