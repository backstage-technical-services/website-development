#!/usr/bin/env bash
repo_base_dir="$(pwd)/$(dirname $0)/.."
cd "${repo_base_dir}"

repository_file="repositories.json"
repositories=$(cat ${repository_file})

# Get path
read -p "Enter the relative path the repo should be cloned to: " path
if [[ -z "${path}" ]]; then echo "Please enter the path the repo should be cloned to"; exit 1; fi

# Check if path already used
existing_path=$(echo "${repositories}" | jq "[.[] | select(.path == \"${path}\")] | length")
if [[ "${existing_path}" != "0" ]]; then echo "" && echo "A repository with that path already exists."; exit 1; fi

# Get repo URL
read -p "Enter the URL to clone the repo with (SSH recommended): " url
if [[ -z "${url}" ]]; then echo "Please enter the URL of the repo"; exit 1; fi

# Add to array
new_repositories=$(echo "${repositories}" | jq ". += [{\"path\": \"${path}\", \"url\": \"${url}\"}]")
echo "${new_repositories}" > "${repository_file}"

# Re-sync
echo "" && echo "Synchronising ..."
.bin/sync_repositories.sh 1> /dev/null
