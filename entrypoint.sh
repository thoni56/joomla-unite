#!/bin/bash
uid="$(id -u)"
gid="$(id -g)"

user="${APACHE_RUN_USER:-www-data}"
group="${APACHE_RUN_GROUP:-www-data}"

# strip off any '#' symbol ('#1000' is valid syntax for Apache)
pound='#'
user="${user#$pound}"
group="${group#$pound}"

# set user if not exist
if ! id "$user" &>/dev/null; then
    # get the user name
    : "${USER_NAME:=www-data}"
    # change the user name
    [[ "$USER_NAME" != "www-data" ]] &&
	usermod -l "$USER_NAME" www-data &&
	groupmod -n "$USER_NAME" www-data
    # update the user ID
    groupmod -o -g "$user" "$USER_NAME"
    # update the user-group ID
    usermod -o -u "$group" "$USER_NAME"
fi

JOOMLA_DB_HOST='localhost'
JOOMLA_DB_USER='joomla'
JOOMLA_DB_PASSWORD='joomla'
JOOMLA_DB_NAME='joomla'

service mysql start
service mariadb start

if [ ! -d administrator ] ; then

    # If there is no administrator directory then we should use UNiTE to get the installation

    # Ensure the MySQL Database is created
    php /makedb.php "$JOOMLA_DB_HOST" "$JOOMLA_DB_USER" "$JOOMLA_DB_PASSWORD" "$JOOMLA_DB_NAME"

    # Ensure timezone data is loaded
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

    # Set up UNiTE executable
    unzip /tmp/unite-package*
    chmod a+x unite.phar
    mv unite.phar unite

    # Restore the site using the unite configuration
    ./unite unite.xml --verbose

    rm index.html
    chown -R www-data:www-data .

    # Trix to ease J4 migration
    grep 'behavior.caption' -lR . | xargs sed -i '/behavior.caption/d'

    echo >&2 "========================================================================"
    echo >&2
    echo >&2 "Joomla UNiTE has restored your site $SITE into this container"
    echo >&2
    echo >&2 "Navigate to this containers http://localhost:{mapped_port}"
    echo >&2
    echo >&2 "JOOMLA_DB_HOST='$JOOMLA_DB_HOST'"
    echo >&2 "JOOMLA_DB_USER='$JOOMLA_DB_USER'"
    echo >&2 "JOOMLA_DB_PASSWORD='$JOOMLA_DB_PASSWORD'"
    echo >&2 "JOOMLA_DB_NAME='$JOOMLA_DB_NAME'"
    echo >&2
    echo >&2 "If you have CiviCRM installed you need to run the script 'civicrm-fix'"
    echo >&2 "before using the new installation:"
    echo >&2
    echo >&2 "    OLD_PATH=/var/www/something OLD_HOST=my.site.com ./civicrm-fix"
    echo >&2
    echo >&2 "========================================================================"

    a2enmod ssl
    a2enconf ssl
    ./generate_certs.sh

else

    echo >&2 "========================================================================"
    echo >&2
    echo >&2 "There is already a Joomla site ($SITE) in this container"
    echo >&2
    echo >&2 "Navigate to this containers http://localhost:{mapped_port}"
    echo >&2
    echo >&2 "JOOMLA_DB_HOST='$JOOMLA_DB_HOST'"
    echo >&2 "JOOMLA_DB_USER='$JOOMLA_DB_USER'"
    echo >&2 "JOOMLA_DB_PASSWORD='$JOOMLA_DB_PASSWORD'"
    echo >&2 "JOOMLA_DB_NAME='$JOOMLA_DB_NAME'"
    echo >&2
    echo >&2 "========================================================================"

fi

service apache2 start

tail -f /var/log/apache2/error.log -f /var/log/apache2/access.log
