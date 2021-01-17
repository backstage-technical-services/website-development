#!/usr/bin/env bash
repo_base_dir="$(pwd)/$(dirname $0)/.."
cd "${repo_base_dir}"

if [[ ! $(ssh-keygen -F github.com) ]]; then
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts &> /dev/null
fi

repository_file="repositories.json"

for repository in $(jq -r '.[] | @base64' "${repository_file}"); do
    repository_decoded=$(echo "${repository}" | base64 --decode)

    path="$(echo "${repository_decoded}" | jq -r '.path')"
    url="$(echo "${repository_decoded}" | jq -r '.url')"

    if [[ ! -d "${path}" ]]; then
        echo "Cloning ${path} from ${url}"
        git clone "${url}" "${path}" &> /dev/null
        pushd "${path}" &> /dev/null && git checkout master &> /dev/null && popd &> /dev/null
    else
        echo "Skipping ${path} as it already exists"
    fi
done
