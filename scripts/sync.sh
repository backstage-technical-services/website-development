#!/usr/bin/env bash
set -eo pipefail

repo_base_dir="$(pwd)/$(dirname $0)/.."
cd "${repo_base_dir}"

if [[ ! $(ssh-keygen -F github.com) ]]; then
    echo ":: Adding SSH keys for github.com"
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi

repository_file="repositories.json"

echo ":: Syncing repositories"

for repository in $(jq -r '.[] | @base64' "${repository_file}"); do
    repository_decoded=$(echo "${repository}" | base64 --decode)

    path="$(echo "${repository_decoded}" | jq -r '.path')"
    url="$(echo "${repository_decoded}" | jq -r '.url')"

    echo "::: ${path}"

    if [[ ! -d "${path}" ]]; then
        echo ":::: Cloning from ${url}"
        git clone "${url}" "${path}"
        
    else
        echo ":::: Skipping cloned as repo is already cloned"
    fi

    echo ":::: Pulling latest from master"
    pushd "${path}" 1> /dev/null
    git checkout master && git pull --ff-only
    popd 1> /dev/null
done

echo ":: Done"
