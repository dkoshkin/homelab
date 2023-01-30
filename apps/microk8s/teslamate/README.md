# Teslamate Setup

This repo contains configuration and instructions on how to run [Teslamate](https://github.com/adriankumpf/teslamate) in [Kubernetes](https://kubernetes.io/) and assumes some prior knowledge of Kubernetes. 

## Prerequisites

* A Kubernetes cluster (tested on a single v1.26.0 Node but any recent version should work)
* Configured `StorageClass`
* [Flux](https://fluxcd.io/flux/get-started/) installed and CLI
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) CLI
* [kubeseal](https://github.com/bitnami-labs/sealed-secrets) CLI
* An [AWS](https://aws.amazon.com/) account to store PostgreSQL backups - see `s3-policy.json` for a minimum S3 policy (replace `<bucket-name`> placeholers)
* Open port `80` - for [Let's Encrypt](https://letsencrypt.org/)
* Open port `443` - for Teslamate and Grafana dashboards

## Set Environment Variables

1. Fill out the env file

```bash
cd <repo>/clusters/microk8s/
mv .env.sample .env
source .env
```

## Setup Teslamate

1. Create a `Secret` with an Encryption key for Teslamate

```bash
kubectl create secret generic teslamate-ecryption-key \
  --namespace teslamate \
  --from-literal ENCRYPTION_KEY=$TESLAMATE_ENCRYPTION_KEY \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=../../../clusters/microk8s/pub-sealed-secrets.pem \
    > secret-teslamate-ecryption-key.yaml
```

2. Generate a `Secret` for Teslamate admin auth

```bash
htpasswd -Bbn $TESLAMATE_USERNAME $TESLAMATE_PASSWORD > teslamate-auth
kubectl create secret generic teslamate-admin-auth \
  --namespace teslamate \
  --from-file=auth=teslamate-auth \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=../../../clusters/microk8s/pub-sealed-secrets.pem \
    > secret-teslamate-admin-auth.yaml
```

3. Create a `Secret` with PostgreSQL details

```bash
kubectl create secret generic postgresql-db-auth \
  --namespace teslamate \
  --from-literal DATABASE_HOST=cluster-postgresql.postgresql \
  --from-literal DATABASE_NAME=teslamate \
  --from-literal DATABASE_USER=$POSTGRES_USERNAME \
  --from-literal DATABASE_PASS=$POSTGRES_PASSWORD \
  --from-literal POSTGRES_HOST=cluster-postgresql.postgresql \
  --from-literal POSTGRES_DATABASE=teslamate \
  --from-literal POSTGRES_USER=$POSTGRES_USERNAME \
  --from-literal POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=../../../clusters/microk8s/pub-sealed-secrets.pem \
    > secret-postgresql-db-auth.yaml
```

4. Create a `Secret` with AWS S3 credentials

```bash
kubectl create secret generic s3-credentials \
  --namespace teslamate \
  --from-literal BACKUP_KEEP_DAYS=7 \
  --from-literal S3_REGION=us-west-2 \
  --from-literal S3_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --from-literal S3_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  --from-literal S3_BUCKET=$S3_BUCKET \
  --from-literal S3_PREFIX=$S3_PREFIX \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=../../../clusters/microk8s/pub-sealed-secrets.pem \
    > secret-s3-credentials.yaml
```

See sample IAM policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::<bucket-name>"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::<bucket-name>/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": "*"
        }
    ]
}
```

## Setup Grafana

1. Create a `SealedSecret` for Grafana admin auth

```bash
kubectl create secret generic grafana-admin-auth \
  --namespace teslamate \
  --from-literal admin-user=$GRAFANA_USERNAME \
  --from-literal admin-password=$GRAFANA_PASSWORD \
  --dry-run=client \
  -o yaml | \
kubeseal \
    --format=yaml \
    --cert=../../../clusters/microk8s/pub-sealed-secrets.pem \
    > secret-grafana-admin-auth.yaml
```

## Restore From a Backup

If you have existing data you can restore it using the following steps.

1. Suspend Flux reconcilation

```bash
flux suspend -n teslamate helmrelease --all
```

2. Scale the teslamate `Deployment` to 0

```bash
kubectl scale deploy -n teslamate teslamate --replicas=0
```

3. Run the a `Pod` to restore from an AWS S3 backup

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: teslamate-backup-restore
  namespace: teslamate
spec:
  containers:
  - name: s3-restore
    image: eeshugerman/postgres-backup-s3:15
    command: ['sh', 'restore.sh']
    envFrom:
    - secretRef:
        name: postgresql-db-auth
    - secretRef:
        name: s3-credentials
  restartPolicy: Never
EOF
``` 

4. Scale the teslamate `Deployment` back to 1

```bash
kubectl scale deploy -n teslamate teslamate --replicas=1
```

5. Resume Flux reconcilation

```bash
flux resume -n teslamate helmrelease --all
```

