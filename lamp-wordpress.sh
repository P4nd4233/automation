#!/bin/bash

apt install -y apache2 unzip expect curl mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

systemctl enable --now apache2 mysql

SECURE_MYSQL=$(expect -c "

set timeout 10
spawn mysql_secure_installation

expect \"Press y|Y for Yes, any other key for No:\"
send \"n\r\"

expect \"New password:\"
send \"VeRySeCuRePlAiNtExTpAsSwOrD\r\"


expect \"Re-enter password:\"
send \"VeRySeCuRePlAiNtExTpAsSwOrD\r\"

expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"

expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"

expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"

expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"

expect eof
")

echo "$SECURE_MYSQL"

apt -y purge expect

mysql -u root -pVeRySeCuRePlAiNtExTpAsSwOrD -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
mysql -u root -pVeRySeCuRePlAiNtExTpAsSwOrD -e "CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'password';"
mysql -u root -pVeRySeCuRePlAiNtExTpAsSwOrD -e "GRANT ALL ON wordpress.* TO 'wordpress_user'@'localhost';"
mysql -u root -pVeRySeCuRePlAiNtExTpAsSwOrD -e "FLUSH PRIVILEGES;"

mkdir /tmp/wp

#wget https://wordpress.org/latest.zip -O /tmp/wp/latest.zip
wget m1/latest.zip -O /tmp/wp/latest.zip

unzip /tmp/wp/latest.zip -d /var/www/

tee /etc/apache2/sites-available/wordpress <<EOF
<Directory /var/www/wordpress/>
	AllowOverride All
</Directory>
EOF

touch /var/www/wordpress/.htaccess
mkdir /var/www/wordpress/wp-content/upgrade

a2enmod rewrite

chown -R www-data:www-data /var/www/wordpress
find /var/www/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/wordpress/ -type f -exec chmod 640 {} \;
sed -i '12s/html/wordpress/' /etc/apache2/sites-available/000-default.conf
systemctl restart apache2
