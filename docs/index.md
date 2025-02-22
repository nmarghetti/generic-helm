# Generic Helm chart

```shell
# Add the helm repository
helm repo add generic-helm https://nmarghetti.github.io/generic-helm

# Dry run installation
helm install --dry-run --output yaml -n apps my-apps generic-helm/generic-chart | yq
helm install --dry-run --output yaml --values ./tests/values-enabled.yaml --values ./tests/values-full.yaml -n apps my-apps generic-helm/generic-chart | yq
```
