# BTS Website Development

This repository holds some useful configuration for grouping all the necessary repositories, 
as well as some docker configuration for useful auxiliary services. 

## Auxiliary services

This repository contains the configuration for the following "auxiliary" services to aid development:
* PostgreSQL database
* SMTP mail server

## Using this repository
The `repositories.json` file holds all the configuration - each repository has:
* `path`: a directory relative to this repository where it should be cloned
* `url`: the URL to use when cloning (SSH recommended)

There are a couple of scripts in the `scripts` directory to help with managing all the repositories:
 
* Once you have cloned this repository, run `scripts/sync_repositories.sh` to clone all the configured repositories.
If someone adds a new repository, simply pull the changes and run `scripts/sync_repositories.sh` again.
    > This will not overwrite any repositories you already have cloned
* If you want to add a repository, you can either add an entry to the `repositories.json` file, or use the 
`scripts/add_repository.sh` script. You can even do this for a repository you don't already have cloned, as it'll
synchronise at the end.

## Running locally

It's recommended you use Docker and the included docker set up for the auxiliary services, but you'll want 
to run the API and SPA manually (see their repositories for more information).

1. Copy the `.env.example` file to `.env` and update any values as needed
2. Run `docker-compose up -d` to boot everything up

## Resetting the database

The database is run as a docker container, and the data is stored in `.docker/data/database` so that rebooting 
the container doesn't result in the data being lost.

If you do want to reset the data, simply delete this directory and restart the database (`docker-compose restart database`).
> You'll need to use administrator privileges to delete this directory

## Helpful commands

**Using the docker compose set-up**
* Start a service: `docker-compose up {service}`
* Start a service in detached mode: `docker-compose up -d {service}`
* Stop a service: `docker-compose stop {service}`
* Restart a service: `docker-compose restart {service}`

**Interacting with the raw container**
* Viewing the logs: `docker logs {container}`
* Following the logs: `docker logs -f {container}`
* Remove the container (to clear temp data): `docker rm {container}`
