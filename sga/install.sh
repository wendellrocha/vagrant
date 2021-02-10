#!/bin/bash
DB='novosga'
USER='novosga'
PASS='ZvqQ820QhCmRUGRaDMKL2yINLR4Lg'
MARIADB_VERSION='10.3'
ROOT_PASS='uUwKXIzNx5Qb1QmgpYFz82XD4zpRR'

sudo apt update
sudo apt upgrade -y

sudo apt install software-properties-common
sudo apt-add-repository ppa:ondrej/php
sudo apt update
sudo apt install -y php7.1 php7.1-mysql php7.1-curl php7.1-zip php7.1-intl php7.1-xml php7.1-mbstring php7.1-gettext

curl -fSL https://getcomposer.org/composer.phar -o composer.phar
php composer.phar create-project "novosga/novosga:^2.0" ~/novosga

sudo apt install apache2 -y
sudo a2enmod rewrite env

sudo mv ~/novosga /var/www/html/

cd /var/www/html/novosga
bin/console cache:clear --no-debug --no-warmup --env=prod
bin/console cache:warmup --env=prod

sudo chown www-data:www-data -R /var/www/novosga
sudo chmod +w -R /var/www/html/novosga/var/

cd ~

sudo sed -i 's|/var/www/html|/var/www/html/novosga/public|g' /etc/apache2/sites-available/000-default.conf
sudo sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

sudo echo 'date.timezone = America/Sao_Paulo' > /etc/php/7.1/apache2/conf.d/datetimezone.ini

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
echo "maria-db-$MARIADB_VERSION mysql-server/root_password password $ROOT_PASS" | sudo debconf-set-selections
echo "maria-db-$MARIADB_VERSION mysql-server/root_password_again password $ROOT_PASS" | sudo debconf-set-selections

sudo apt install -y mariadb-server

# Run the MySQL Secure Installation wizard
mysql_secure_installation

sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
mysql -uroot -p -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES;'

mysql -uroot -p -e "create database $DB character set utf8 collate utf8_bin;"
mysql -uroot -p -e "create user '$USER'@'localhost' identified with mysql_native_password by '$PASS';"
mysql -uroot -p -e "grant all privileges on $DB.* to '$USER'@'localhost' with grant option"
mysql -uroot -p -e "FLUSH PRIVILEGES;"

service mysql restart

echo 'Options -MultiViews
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ index.php [QSA,L]
SetEnv APP_ENV prod
SetEnv LANGUAGE pt_BR
SetEnv DATABASE_URL mysql://novosga:ZvqQ820QhCmRUGRaDMKL2yINLR4Lg@mysqldb:3306/novosga2?charset=utf8mb4&serverVersion=5.7
' > /var/www/html/novosga/public/.htaccess

sudo service apache2 restart

cd /var/www/html/novosga
APP_ENV=prod \
    LANGUAGE=pt_BR \
    DATABASE_URL="mysql://novosga:ZvqQ820QhCmRUGRaDMKL2yINLR4Lg@mysqldb:3306/novosga2?charset=utf8mb4&serverVersion=5.7" \
    bin/console novosga:install