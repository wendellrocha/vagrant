sudo apt install -y apt-transport-https
sudo apt install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt update

sudo apt install grafana

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server

sudo systemctl enable grafana-server.service

grafana-cli plugins install alexanderzobnin-zabbix-app
grafana-cli plugins install grafana-piechart-panel