#!/usr/bin/env bash
set -eo pipefail
readonly rootDir="$(dirname "$(realpath "${0}")")/.."

# Ensure that Docker is running...
if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running." >&2
  exit 1
fi

function _showHelp() {
  cat <<EOF
###################
##  BTS Website  ##
###################

This scripts provides some helpful utility functions for interacting
with the local Docker container, to aid with local development.

Commands:
  docker [OPTIONS] COMMAND
    Run any normal docker-compose command.
  start
    Start the site and dependencies.
  stop
    Stop the site and dependencies.
  status
    View the status of the docker containers.
  rebuild
    Pull the latest base image and rebuild the site's docker image
    and container.
  exec COMMAND
    Run any command inside the container.
  composer [OPTIONS] COMMAND
    Run any composer command.
  yarn [OPTIONS] COMMAND
    Run any yarn script (alias for yarn run).
  install [--update]
    Install both the PHP and JavaScript dependencies. Use the --update
    flag to update the dependencies to their latest versions.
  artisan COMMAND
    Run any artisan command.
  build-assets
    Build the JavaScript and CSS assets.
  watch-assets
    Build the JavaScript and CSS assets, and rebuild on any changes.
  update
    Update your local copy of the site, including installing any new
    dependencies, re-building the assets and running any new migrations.
  help
    Show this information.
EOF
}

function _docker() {
  docker-compose -f "$rootDir/docker-compose.yml" "$@"
}

function _start() {
  _docker up -d
}

function _stop() {
  _docker down
}

function _requireRunning() {
  _docker ps | grep site &>/dev/null || {
    echo "Site not running. Run start and try again." >&2
    exit 2
  }
}

function _status() {
  _docker ps
}

function _rebuild() {
  local githubTokenFile="$rootDir/.github_token"

  # Stop the network
  _stop

  # Process the GitHub token
  if [[ -n "$GITHUB_TOKEN" ]]; then
    echo "$GITHUB_TOKEN" >"$githubTokenFile"
  fi

  if [[ ! -f "$githubTokenFile" ]]; then
    cat <<EOF >&2
No GitHub token.

Generate an new access token with the read:packages scope from:
    Settings > Developer settings > Personal access tokens

Once generated, either export this in a GITHUB_TOKEN environment
variable, or in a .github_token file.
EOF
  fi

  # Check for the GITHUB_USERNAME variable
  if [[ -z "$GITHUB_USERNAME" ]]; then
    cat <<EOF >&2
No GitHub username specified.

Export your GitHub username in the GITHUB_USERNAME environment
variable.
EOF
  fi

  # Log into the registry and pull the base image
  cat "${githubTokenFile}" | docker login docker.pkg.github.com -u "${GITHUB_USERNAME}" --password-stdin
  _docker pull site

  # Rebuild the site
  _docker build \
    --build-arg="USER_ID=$(id -u "${USER}")" \
    --build-arg="GROUP_ID=$(id -g "${USER}")" \
    site

  # Start
  _start
}

function _exec() {
  _requireRunning
  _docker exec site "$@"
}

function _composer() {
  _exec composer "$@"
}

function _artisan() {
  _exec php artisan "$@"
}

function _yarn() {
  _exec yarn run "$@"
}

function _install() {
  _requireRunning

  if [[ "${1}" == "--update" ]]; then
    _composer update
    _exec yarn update
  else
    _composer install
    _exec yarn
  fi
}

function _buildAssets() {
  _requireRunning

  _yarn dev
}

function _watchAssets() {
  _requireRunning

  _yarn watch
}

function _test() {
  _requireRunning

  _artisan test
}

function _update() {
  _requireRunning

  pushd "${rootDir}/laravel-site" &>/dev/null

  echo "Updating your local copy ..."
  git pull -ff-only &>/dev/null

  echo "Installing dependencies ..."
  _install &>/dev/null

  echo "Building assets ..."
  _buildAssets &>/dev/null

  echo "Running migrations ..."
  _artisan migrate

  echo "Clearing the cache ..."
  _artisan cache:clear &>/dev/null
  _artisan view:clear &>/dev/null
  _artisan config:clear &>/dev/null

  echo "Done."

  popd &>/dev/null
}

readonly cmd="${1}"
shift

case $cmd in
docker)
  _docker "$@"
  ;;
start)
  _start
  ;;
stop)
  _stop
  ;;
status)
  _status
  ;;
rebuild)
  _rebuild
  ;;
exec)
  _exec "$@"
  ;;
composer)
  _composer "$@"
  ;;
yarn)
  _composer "$@"
  ;;
install)
  _install "$@"
  ;;
artisan)
  _artisan "$@"
  ;;
build-assets)
  _buildAssets
  ;;
watch-assets)
  _watchAssets
  ;;
test)
  _test
  ;;
update)
  _update
  ;;
help)
  _showHelp
  ;;
*)
  _showHelp
  ;;
esac
