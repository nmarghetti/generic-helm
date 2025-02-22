# Generic Helm chart

Check <https://nmarghetti.github.io/generic-helm/> for usage.

## Init repository

```shell
# Init submodules
git submodule update --init
cd scripts/utils &&
  git sparse-checkout set --no-cone '/log.sh' &&
  cd -

# Upgrade submodules
git submodule update --remote
```

## Unit test

First ensure to install helm unit test plugin `helm plugin install https://github.com/quintush/helm-unittest --version v0.2.9`.
You can also update it with `helm plugin update unittest`.

You can get the templates list for `helm/tests/*_test.yaml` with `find helm/templates -name "*.yaml" -o -name "*.yml" | sort | sed -re 's#helm/templates/# - #'`

```shell
# test the helm chart
helm unittest ./generic-chart -f '../tests/*_test.yaml'
# update tha snapshots
helm unittest ./generic-chart -f '../tests/*_test.yaml' -u
```

## Check the helm

```shell
# Check the template generation
helm template ./generic-chart --debug | yq

# Check with values
helm template ./generic-chart --values ./tests/values-base.yaml --values ./tests/values-enabled.yaml --values ./tests/values-full.yaml --debug
helm template ./generic-chart --values ./examples/values-flux-playground_traefik-minikube-vault-helm.yaml --debug

# Lint the helm
helm lint ./generic-chart
```

## Check installation

```shell
# Check the files embedded inside the helm, there should be none
helm install apps ./generic-chart --dry-run --output json | jq -r '.chart.files[]?.name'
# Check the templates embedded inside the helm
helm install apps ./generic-chart --dry-run --output json | jq -r '.chart.templates[].name'
# Check the full content
helm install apps ./generic-chart --dry-run --output yaml | yq
# Check the full content with values
helm install apps ./generic-chart --values ./tests/values-enabled.yaml --values ./tests/values-full.yaml --dry-run --output yaml | yq
```

## Release

Increase the chart version in [Chart.yaml](Chart.yaml) and commit it.

```shell
./release.sh
```
