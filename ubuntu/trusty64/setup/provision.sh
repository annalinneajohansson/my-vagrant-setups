#!/usr/bin/env bash

function say {
    printf "\n--------------------------------------------------------\n"
    printf "$1"
	printf "\n--------------------------------------------------------\n"
}

BaseDocumentRoot=$1

chown -R vagrant:vagrant /usr/local/bin
mkdir -p "$BaseDocumentRoot/html"

say "Removing the /var/www directory and instead creating a symbolic link from it to $BaseDocumentRoot"
	rm -rf /var/www
	ln -fs $BaseDocumentRoot /var/www

# Install Apache
say "Installing Apache"
    # Update aptitude library
    apt-get update >/dev/null 2>&1
    # Install apache2 
    apt-get install -y apache2 >/dev/null 2>&1
    # Enable mod_rewrite
    a2enmod rewrite  >/dev/null 2>&1


# Install mysql
say "Installing MySQL."
export DEBIAN_FRONTEND=noninteractive

	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

    apt-get update  >/dev/null 2>&1
    apt-get install -y mysql-server >/dev/null 2>&1
    sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
    service mysql stop >/dev/null 2>&1
	service mysql start >/dev/null 2>&1
    mysql -u root -proot <<< "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password'; FLUSH PRIVILEGES;"  >/dev/null 2>&1

say "Installing PHP"
    apt-get install -y php5 php5-cli php5-common php5-dev php5-imagick php5-imap php5-gd libapache2-mod-php5 php5-mysql php5-curl >/dev/null 2>&1
	# Restart Apache
	service apache2 restart >/dev/null 2>&1

say "Installing PHPMyAdmin"

	PASS="root"

	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections >/dev/null 2>&1
	echo "phpmyadmin phpmyadmin/app-password-confirm password $PASS" | debconf-set-selections >/dev/null 2>&1
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PASS" | debconf-set-selections >/dev/null 2>&1
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $PASS" | debconf-set-selections >/dev/null 2>&1
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections >/dev/null 2>&1

	apt-get install -y phpmyadmin php5-gettext >/dev/null 2>&1
	phpenmod mcrypt  >/dev/null 2>&1
	phpenmod mbstring  >/dev/null 2>&1

	# Restart Apache
	service apache2 restart >/dev/null 2>&1

say "Installing some good-to-have packages such as curl and git"
    apt-get install -y curl git ftp unzip imagemagick colordiff gettext graphviz >/dev/null 2>&1

say "Installing ruby"
	apt-get install ruby -y >/dev/null 2>&1

say "Installing wp-cli"
    cd ~

	curl -s -S -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >/dev/null 2>&1
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp

	curl -s -S https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash > wp-completion.bash
	
	echo "source /home/vagrant/wp-completion.bash" >> ~/.bashrc
	source ~/.bashrc

say "Provisioning done."