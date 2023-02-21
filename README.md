# joomla-unite

Use Akeeba UNiTE to clone your Joomla website into a Docker container with a LAMP-stack.

## Configuration

- Configure your UNiTE restore in the unite.xml.template.

- Specify which LAMP stack you want (jammy-8.0 e.g.) in the Makefile.

Run `make` which will configure a Dockerfile with the correct Ubuntu and PHP versions which is then built.

The resulting Docker image will have the UNiTE configuration and some necessary scripts.

## Running

When starting the image, UNiTE will try to backup, download and restore the site specified in the `unite.xml`.

If you have `CiviCRM` installed you need to tweek the configuration of
that using the `civicrm-fix` script as described in the console of the
Docker container.

Navigate to your container and enjoy!

