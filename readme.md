# BTS Website Development

> Make sure you are familiar with the [Contribution
> Guide][contribution-guide] and [our tools][development-tools].

This repository is intended to be the starting point for anyone who
wants to get the BTS website running locally. It ensures that everything
is set up as we'd expect, to help with debugging, and includes the
necessary [auxiliary services](#running-the-auxiliary-services).

## Pre-requisites

Please make sure you have [the pre-requisites set up][prerequisites].

## Getting started

To get started, simply navigate to where you want to download this
repository (we recommend setting a new folder up to keep everything
organised) and run

```sh
$ git clone git@github.com:backstage-technical-services/website-development.git development
```

This will download this repository into a `development` directory.

## Downloading the website

Downloading the website is simple; all you need to do is navigate into
the `development` directory and run

```sh
$ scripts/sync.sh
```

This will download the website into the correct folder, and help ensure
everything is grouped together nicely.

## Running the auxiliary services

This repository also contains the configuration for the required
auxiliary services:

* MariaDB database
* SMTP (mail) server

Make a copy of `.env.example` called `.env`; this file contains the port
configuration for these services, as well as the username and password
used to connect to the database. You can change these values to whatever
you want, just make sure to use your values rather than those in the
readme files.

> If you change the value of `DB_USERNAME` you will also need to change
> `developer` to this value in `.docker/init/database/site.sql` so that
> your API is given the correct permissions.
>
> ```mysql
> GRANT ALL PRIVILEGES ON `backstage`.* TO 'developer'@'%';
> ```

Once the environment file is set up, you can start the services with

```sh
$ docker-compose up -d
```

You can stop them with

```sh
$ docker-compose stop
```

### Connecting to the database

The database is exposed on the `PORT_DATABASE` port (default `6011`) so
you can connect to it using your database manager of choice. Just
configure it with the following:

* Host: `localhost`
* Port: `<PORT_DATABASE>`
* Username: `<DB_USERNAME>`
* Password: `<DB_PASSWORD>`

### Initialising the data

The API will include the necessary config to initialise some test data,
but if you want to use some data more akin to what will be used in
production you can ask in [Slack][slack] and then use your database tool
to import it.

### Resetting the data

Having to re-import all the data every time the database (or your
computer) reboots would be rather tedious, so the database is configured
to store its data in `.docker/data/database`.

However if you do want to reset your database, you can either `TRUNCATE`
the tables using your database manager, or delete the contents of this
directory and then restart the database (`docker-compose restart -d
database`).

### Viewing emails

Included in the Docker set-up is a local SMTP server. This doesn't
actually send any emails, so you're free to test with any email address,
and provides a user interface for viewing any emails that have been
sent.

You can connect to this SMTP server using the port `PORT_MAIL_SMTP` and
view the interface at [http://localhost:6012][smtp-ui] (unless you've
changed the value of `PORT_MAIL_UI` in your `.env` file).

## Notes for running locally

1. Make sure you've logged into the docker registry to download the base
   image
   * Create a personal token in GitHub

     ```
     Settings > Developer settings > Personal access tokens
     ```
   * Log into the registry

     ```sh
     $ echo "<token>" | docker login docker.pkg.github.com -u <github-username> --password-stdin
     ```
2. Make sure you configure your user ID and group ID
   * Run `id $(whoami)`
   * Set these as the `USER_ID` and `GROUP_ID` in `docker-compose.yml`
3. Run it!
    ```sh
   $ docker-compose up -d
    ```

## Helpful commands

Here are some helpful commands for interacting with the docker
containers.


* Start a service

  ```sh
  $ docker-compose up -d <service>
  ```

* Follow the logs

  ```sh
  $ docker-compose logs -f <service>
  ```

* Stop a service

  ```sh
  $ docker-compose stop <service>
  ```

* Remove the container (in case you want to reset any stored data)

  ```sh
  $ docker-compose rm <service>
  ```

* Restart a service

  ```sh
  $ docker-compose restart <service>
  ```

* Stop all services and clean up

  ```sh
  $ docker-compose down  
  ```

[prerequisites]: https://github.com/backstage-technical-services/hub/blob/master/docs/contributing/Developing.md#pre-requisites
[contribution-guide]: https://github.com/backstage-technical-services/hub/blob/master/Contributing.md
[development-tools]: https://github.com/backstage-technical-services/hub/blob/master/docs/Our%20Tools.md
[slack]: https://bts-website.slack.com
[smtp-ui]: http://localhost:6022
[keycloak-account]: https://keycloak.bts-crew.com/auth/realms/nonprod/account

