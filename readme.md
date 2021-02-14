# BTS Website Development

> Make sure you are familiar with the [Contribution
> Guide][contribution-guide] and [our tools][development-tools].

This repository is intended to be the starting point for anyone who
wants to get the BTS website running locally. It ensures that everything
is set up as we'd expect, to help with debugging, and includes the
necessary [auxiliary services](#auxiliary-services).

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

## Running the site

To avoid needing to install and configure Nginx, PHP-FPM, Composer, NPM
and Yarn this site includes a Docker container that includes all of this
pre-build and pre-configured. This container creates a volume mount
between `/var/www` (where the site is configured to be served from) and
the `laravel-site` directory.This means that any changes you make
locally are also changed in the docker container, without the need to
re-build and restart the container.

> A caveat to this is that the file watcher between your computer and
> Docker can make your computer slow and can exceed the operating system
> limit. This can sometimes be resolved by stopping and then starting
> the container again.

As you will not have PHP etc installed on your computer, any commands
you need to perform to manage the site will need to be run on the Docker
container. This repository also includes a
[helpful script](scripts/site.sh) for managing the site:

* `scripts/site.sh start` to start the site and auxiliary services.
* `scripts/site.sh stop` to stop the site and auxiliary services.
* `scripts/site.sh install` to install any dependencies.
* `scripts/site.sh watch-assets` to build JS/CSS assets and
  automatically re-build any changes.
* `scripts/site.sh artisan COMMAND` to run any artisan command.
* `scripts/site.sh test` to run any PHPUnit tests.
* `scripts/site.sh update` to update your copy of the site and install
  any new dependencies.
* `scripts/site.sh rebuild` to rebuild the container (eg, if the version
  of PHP changes).
* `scripts/site.sh help` to see more information.

## Auxiliary services

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

### Connecting to the database

The database is exposed on the `PORT_DATABASE` port (default `6011`) so
you can connect to it using your database manager of choice. Just
configure it with the following:

* Host: `localhost`
* Port: `<PORT_DATABASE>`
* Username: `<DB_USERNAME>`
* Password: `<DB_PASSWORD>`

### Initialising the data

The site does not seed any dummy data, but you can ask in [Slack][slack]
for some initial data and then use your database tool to import it.

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

[prerequisites]: https://github.com/backstage-technical-services/hub/blob/master/docs/contributing/Developing.md#pre-requisites
[contribution-guide]: https://github.com/backstage-technical-services/hub/blob/master/Contributing.md
[development-tools]: https://github.com/backstage-technical-services/hub/blob/master/docs/Our%20Tools.md
[slack]: https://bts-website.slack.com
[smtp-ui]: http://localhost:6022

