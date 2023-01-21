#!/bin/bash
PHP=$1

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

# Ensure the MySQL Database is created
php$PHP /makedb.php "$JOOMLA_DB_HOST" "$JOOMLA_DB_USER" "$JOOMLA_DB_PASSWORD" "$JOOMLA_DB_NAME"

# Set up UNiTE executable
unzip /tmp/unite-package*
chmod a+x unite.phar
mv unite.phar unite

# Restore the site using the unite configuration
./unite unite.xml

rm index.html
chown -R www-data:www-data .

a2enmod ssl
a2enconf ssl
./generate_certs.sh
service apache2 start

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
echo >&2 "========================================================================"

tail -f /var/log/apache2/error.log -f /var/log/apache2/access.log
