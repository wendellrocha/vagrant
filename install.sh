wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-5.0.7.tar.gz

tar -zxvf zabbix-5.0.7.tar.gz

sudo groupadd zabbix
sudo useradd -g zabbix zabbix

sudo apt install build-essential pkg-config

sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:ondrej/apache2
sudo apt install -y php8.0
sudo apt install apache2 libapache2-mod-php8.0 php8.0-gd php8.0-bcmath php8.0-common php8.0-xml php-net-socket php8.0-mbstring
sudo apt install php8.0-mysql mysql-server mysql-client libmysqlclient-dev

sudo apt install ipmitool libssh2-1-dev fping libcurl4 snmpd snmp libsnmp-dev libxml2-dev libevent-dev libcurl3-dev libpcre3-dev libssl-dev

sudo mysql_secure_installation

$mysql -uroot -p
password
mysql> create database zabbix character set utf8 collate utf8_bin;
mysql> create user 'zabbix'@'<serverID>' identified with mysql_native_password by '<NewZabbixPassword>';
mysql> grant all privileges on zabbix.* to 'zabbix'@'<serverID>' with grant option;
mysql> quit;

./configure --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2


CONF_SERVER=/usr/local/etc/zabbix_server.conf

SENHA="zabbix";
SENHAROOT="zabbix_root";
NOMEBANCO="zabbix";
USUARIODB="zabbix";

mv $CONF_SERVER $CONF_SERVER.ori.$$
echo "DBUser=$USUARIODB" > $CONF_SERVER
echo "DBPassword=$SENHA" >> $CONF_SERVER
echo "DBName=$NOMEBANCO" >> $CONF_SERVER
echo "CacheSize=32M" >> $CONF_SERVER

echo "DebugLevel=3" >> $CONF_SERVER
echo "PidFile=/tmp/zabbix_server.pid" >> $CONF_SERVER
echo "LogFile=/tmp/zabbix_server.log" >> $CONF_SERVER
echo "Timeout=3" >> $CONF_SERVER

PATH_FPING=$(which fping);
echo "FpingLocation=$PATH_FPING" >> $CONF_SERVER

#zabbix_server.service
[Unit]
Description=Zabbix Server
After=syslog.target network.target mysqld.service
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/zabbix_server -c /usr/local/etc/zabbix_server.conf
ExecReload=/usr/local/sbin/zabbix_server -R config_cache_reload
RemainAfterExit=yes
PIDFile=/tmp/zabbix_server.pid
[Install]
WantedBy=multi-user.target

/misc/init.d/debian/zabbix-server /etc/init.d/zabbix-server
update-rc.d -f zabbix-server defaults

#zabbix_agentd.conf
CONF_AGENTE=/usr/local/etc/zabbix_agentd.conf

# Backup do arquivo original do agente, importante guarda-lo para referencias
mv $CONF_AGENTE $CONF_AGENTE.ori.$$

# Criando um arquivo de configuração do agente minimizado
cd $SOURCE_DIR
echo "Server=127.0.0.1" > $CONF_AGENTE
echo "StartAgents=3" >> $CONF_AGENTE
echo "DebugLevel=3" >> $CONF_AGENTE
echo "Hostname=$(hostname)" >> $CONF_AGENTE
echo "PidFile=/tmp/zabbix_agentd.pid" >> $CONF_AGENTE
echo "LogFile=/tmp/zabbix_agentd.log" >> $CONF_AGENTE
echo "Timeout=3" >> $CONF_AGENTE
echo "EnableRemoteCommands=1" >> $CONF_AGENTE

#zabbix_agentd.service
[Unit]
Description=Zabbix Agent
After=syslog.target network.target
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/zabbix_agentd -c /usr/local/etc/zabbix_agentd.conf
RemainAfterExit=yes
PIDFile=/tmp/zabbix_agentd.pid
[Install]
WantedBy=multi-user.target

/misc/init.d/debian/zabbix-agentd /etc/init.d/zabbix-agentd
update-rc.d -f zabbix-agentd defaults

sed -i 's/max_execution_time/\;max_execution_time/g' $PHPFILE;
echo ' max_execution_time=300'>> $PHPFILE;
sed -i 's/max_input_time/\;max_input_time/g' $PHPFILE;
echo 'max_input_time=300' >> $PHPFILE;
sed -i 's/date.timezone/\;date.timezone/g' $PHPFILE;
echo ' date.timezone=America/Sao_Paulo' >> $PHPFILE;

sed -i 's/post_max_size/\;post_max_size/g' $PHPFILE;
echo ' post_max_size=16M' >> $PHPFILE;

sudo touch /var/www/html/zabbix/zabbix.conf.php
sudo chmod 777 /var/www/html/zabbix/zabbix.conf.php 
