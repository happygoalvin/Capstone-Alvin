# Deploy Wordpress on my private webapp instance

## use SSH Agent forwarding to access private instances

### Change permissions of the .pem key file so only root user can read it
chmod 400 alvin-keypair-sydney.pem

### Configure SSH Agent on MacOS
ssh-add ---apple-use-keychain alvin-keypair-sydney.pem

### Configure the SSH Agent on Linux
ssh-add -L alvin-keypair-sydney.pem

### Connect to the bastion host instance on MacOS
ssh -A ec2-user@<bastion-IP-address or DNS-entry>

### Connect to private instances from bastion host
ssh ec2-user@<instance-IP-address or DNS-entry>

### Install MySQL and attempt to tcp into DB
sudo yum install -y mysql
export MYSQL_HOST=<your-endpoint>
mysql --user=admin --password=hWOKAlFBI7b0gv5HtJsl alvindb

### Install Apache2
sudo yum install -y httpd
sudo service httpd start

### Set httpd to listen on port 8080 on my private webapp instance
sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

### Download Wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cd wordpress
cp wp-config-sample.php wp-config.php
sudo vi wp-config.php

### CONFIG Files to Change
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'alvindb' );

/** MySQL database username */
define( 'DB_USER', 'admin' );

/** MySQL database password */
define( 'DB_PASSWORD', 'hWOKAlFBI7b0gv5HtJsl' );

/** MySQL hostname */
define( 'DB_HOST', 'alvin-wordpress-db.cgjnxxvhhdwq.ap-southeast-2.rds.amazonaws.com' );

/** MySQL Database charset to use in creating database tables. */
define ( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE, '');

### Authentication Unique Keys and Salts
define('AUTH_KEY',         'ObC,m@r8$*69UIZoX9D-MY=v-&]Uf_B_Ba^eY3y7T)(H#2K+9/$w7|i_Bu{Mn.^z');
define('SECURE_AUTH_KEY',  '_$-Rj^.H4W1C^Y D|Xkq)C|R,WFQxbK<Sbr.(-kNZ.v@7Hj#=@C<#C-Pr8~c}[f!');
define('LOGGED_IN_KEY',    '}!<%^*?JvJVcFy>ZLp>!vTQ,67fdMb3x@5>QD.$WuY<f:SS&;T42|<-aI#?V.5|M');
define('NONCE_KEY',        ']<&h-z]jJ<v08xZaHR9J$>eA#<2Q-?KeE~vx1+yp0!W_3I OB=+c:AdU0@4;)AFF');
define('AUTH_SALT',        '^*|x;?>-]d!Tq.oZmi;wpx}_kR_?DpZ-fIctOsqPLzd&*W$ZiYe0*k<Y7[ZE,6z=');
define('SECURE_AUTH_SALT', 'Vc<(l<1 ,J;GMMiQMr(WXr,|X+^1KP;9o=8S9;8{(M$g}bU:{Em|bLdyL5(b~fzu');
define('LOGGED_IN_SALT',   '^~KA2;vRT>7;>O]T5n`/o)<~:J<wg<M<Kpnt=le3VYK{i!KmZw-gV+7J`nI_:KhY');
define('NONCE_SALT',       'Sh/+z=)|Xew9R+qSCX-f*Z,X6MsV.}[.`k;BE;:`i|8X-T*@89v8m`5$X0,PA,Qi');

### Deploying Wordpress

sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cd /home/ec2-user
sudo cp -r wordpress/* /var/www/html/
sudo service httpd restart
