#!/bin/bash
set -e

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
	if [ -n "$MYSQL_PORT_3306_TCP" ]; then
		if [ -z "$CONCRETE5_DB_HOST" ]; then
			CONCRETE5_DB_HOST='mysql'
		else
			echo >&2 'warning: both CONCRETE5_DB_HOST and MYSQL_PORT_3306_TCP found'
			echo >&2 "  Connecting to CONCRETE5_DB_HOST ($CONCRETE5_DB_HOST)"
			echo >&2 '  instead of the linked mysql container'
		fi
	fi

	if [ -z "$CONCRETE5_DB_HOST" ]; then
		echo >&2 'error: missing CONCRETE5_DB_HOST and MYSQL_PORT_3306_TCP environment variables'
		echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
		echo >&2 '  with -e CONCRETE5_DB_HOST=hostname:port?'
		exit 1
	fi

	# if we're linked to MySQL and thus have credentials already, let's use them
	: ${CONCRETE5_DB_USER:=${MYSQL_ENV_MYSQL_USER:-root}}
	if [ "$CONCRETE5_DB_USER" = 'root' ]; then
		: ${CONCRETE5_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
	fi
	: ${CONCRETE5_DB_PASSWORD:=$MYSQL_ENV_MYSQL_PASSWORD}
	: ${CONCRETE5_DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE:-wordpress}}

	if [ -z "$CONCRETE5_DB_PASSWORD" ]; then
		echo >&2 'error: missing required CONCRETE5_DB_PASSWORD environment variable'
		echo >&2 '  Did you forget to -e CONCRETE5_DB_PASSWORD=... ?'
		echo >&2
		echo >&2 '  (Also of interest might be CONCRETE5_DB_USER and CONCRETE5_DB_NAME.)'
		exit 1
	fi

	if ! [ -e concrete/dispatcher.php -a ]; then
		echo >&2 "Concrete5 not found in $(pwd) - copying now..."
		if [ "$(ls -A)" ]; then
			echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
			( set -x; ls -A; sleep 10 )
		fi

		if [ ! -d /usr/src/concrete5 ]; then
			curl -SL https://ja.osdn.net/dl/usagi/concrete${CONCRETE5_VERSION:=5.5.2.1}.ja.zip | unzip -d /usr/src/concrete5 \
			&& chown -R www-data:www-data /usr/src/concrete5
		fi

		tar cf - --one-file-system -C /usr/src/concrete5 . | tar xf -
		echo >&2 "Complete! Concrete5 has been successfully copied to $(pwd)"
		if [ ! -e .htaccess ]; then
			# NOTE: The "Indexes" option is disabled in the php:apache base image
			cat > .htaccess <<-'EOF'
				<IfModule mod_rewrite.c>
				RewriteEngine On
				RewriteBase /
				RewriteCond %{REQUEST_FILENAME} !-f
				RewriteCond %{REQUEST_FILENAME} !-d
				RewriteRule ^(.*)$ index.php/$1 [L]
				</IfModule>
			EOF
			chown www-data:www-data .htaccess
		fi

	fi

exec "$@"
