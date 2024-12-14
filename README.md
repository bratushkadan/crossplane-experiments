# Crossplane experiments

## Scripts

### Start/stop cluster

1. Make sure you're in root directory;
2. Populate .yc.env with k8s cluster id and k8s node group;
3. Run `./scripts/resource.sh start` or  `./scripts/resource.sh stop`;

## Update charts

```bash
export HELM_EXPERIMENTAL_OCI=1
helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/crossplane/crossplane --untar --untardir=charts --version=1.15.1
```

## Fill values

Get SA key:

```bash
CROSSPLANE_SA_IAM_KEY_ID=ajet791nd816ghchdjiq;
CROSSPLANE_SA_LOCKBOX_IAM_KEY_SECRET_ID=e6q6cvhr0cq1nvhhbgga;
PRIVATE_KEY=$(yc --profile cloud-danilabratushka lockbox payload get "${CROSSPLANE_SA_LOCKBOX_IAM_KEY_SECRET_ID}" | yq -Mr -o json '.entries[] | select (.key == "private_key") | .text_value'); yc --profile cloud-danilabratushka iam key get "${CROSSPLANE_SA_IAM_KEY_ID}" --format json --full | jq -M --arg private_key "${PRIVATE_KEY}" '.private_key = $private_key | del(.description)' > sa-key.json
```

Install helm chart in the cluster:
```bash
helm install \
  --namespace crossplane-system \
  --create-namespace \
  --set-file providerJetYc.creds=key.json \
  crossplane ./crossplane/
```

