#!/bin/sh
set -e

umask 0002
su www

if [ ! -e wp-config.php ]; then
	wp core download	--path=/var/www 				\
						--locale=en_US					\
						--version=6.4.1
	wp config create	--force 						\
						--skip-check 					\
						--dbhost=mariadb				\
						--dbuser=$MYSQL_USER_ID			\
						--dbpass=$MYSQL_USER_PASSWORD	\
						--dbname=$MYSQL_DATABASE
fi

if ! wp core is-installed; then
	wp core install --locale=en_US 							\
					--url=${DOMAIN}							\
					--title=Inception						\
					--admin_user=${WP_ADMIN_ID}				\
					--admin_email=${WP_ADMIN_EMAIL}			\
					--admin_password=${WP_ADMIN_PASSWORD}
	wp user create	${WP_USER_ID}							\
					${WP_USER_EMAIL} 						\
					--user_pass=${WP_USER_PASSWORD}
fi


php-fpm81 -F

exit
