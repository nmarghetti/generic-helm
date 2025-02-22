#! /bin/bash

cd "$(dirname "$(readlink -f "$0")")" || {
  echo "Unable to go to parent folder of $0" >&2
  exit 1
}

. ./scripts/utils/log.sh

version=$(yq -r '.version' <Chart.yaml)
chart_name=$(yq -r '.name' <Chart.yaml)
tarball="$chart_name-$version.tgz"
build_path="./docs"

run_command mkdir -p "$build_path" || exit_error "Failed to create build directory."
run_command helm lint . || exit_error "Helm lint failed."
run_command helm unittest . || exit_error "Helm unittest failed."
run_command git fetch --force --tags || exit_error "Failed to fetch tags."
run_command git tag -l "$version" | run_command_piped_eval ! grep -qFx "$version" 2>/dev/null || exit_error "Tag '$version' already exists, please update Chart.yaml."
run_command git symbolic-ref --short HEAD | run_command_piped grep -qFx "main" || exit_error "You are not on the main branch."
[ -z "$(run_command git ls-files --directory --no-empty-directory --exclude-standard -ic)" ] || exit_error "You have unwanted files commited in the repository. Please remove them first."
[ -z "$(run_command git status --porcelain)" ] || exit_error "There are uncommitted changes / untracked files. Please commit or stash them before releasing."
run_command helm package . -d "$build_path" || exit_error "Helm package failed."
# shellcheck disable=SC2012
run_command tar -tzf "${build_path}/${tarball}"
# shellcheck disable=SC2012
run_command tar -tzf "${build_path}/${tarball}" | run_command_piped_nerr grep -vE '^'"$chart_name"'/(Chart.yaml|values.yaml|templates)' | run_command_piped_nerr grep --color=always "${chart_name}/" && exit_error "Helm chart contains unwanted files in the archive."
run_command helm repo index "${build_path}" --url https://nmarghetti.github.io/generic-helm/ || exit_error "Helm repo index failed."
run_command git add "${build_path}/${tarball}" "${build_path}/index.yaml" || exit_error "Failed to add the release files to git."
run_command git commit -m "Release $version" || exit_error "Failed to commit the release."
run_command git tag "v$version" || exit_error "Failed to tag the release."
run_command git push --atomic origin main "v$version" || exit_error "Failed to push the release."

log_info "Helm chart release $(yq -r '.name' <Chart.yaml):$version has been successfully pushed."
