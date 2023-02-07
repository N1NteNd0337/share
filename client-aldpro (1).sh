#!/bin/bash 


#set -x

LEVEL=`astra-modeswitch get`

case $LEVEL in
0|1)

        astra-modeswitch set 2
        echo "Уровень безопасности: Смоленск"
        ;;

2)
        echo "Уровень безопасности: Смоленск"
        ;;
esac


#Добавление репозиториев Astra Linux
cat <<EOL > /etc/apt/sources.list
deb http://download.astralinux.ru/astra/frozen/1.7_x86-64/1.7.2/repository-base 1.7_x86-64 main non-free contrib
deb http://download.astralinux.ru/astra/frozen/1.7_x86-64/1.7.2/repository-extended 1.7_x86-64 main contrib non-free
EOL

#Добавление репозиториев ALD Pro
cat <<EOL > /etc/apt/sources.list.d/aldpro.list
deb https://download.astralinux.ru/aldpro/stable/repository-main/ 1.3.0 main
deb https://download.astralinux.ru/aldpro/stable/repository-extended/ generic main
EOL

#Установка приоритетов репозиториев
cat <<EOL > /etc/apt/preferences.d/aldpro
Package: *
Pin: release n=generic
Pin-Priority: 900
EOL

#Настройка hostname
echo -n "Введите HOSTNAME: "
read HOSTNAME
echo -n "HOSTNAME: $HOSTNAME "
echo -e "$HOSTNAME" > /etc/hostname
NAME=`awk -F"." '{print $1}' /etc/hostname`

#Настройка сети
echo -n "Введите статический ipv4 address: "
read IPV4
echo -n "Введите mask (Пример: 255.255.255.0): "
read MASK
echo -n "Введите gateway: "
read GATEWAY
echo -n "Введите ipv4 DC aldpro: "
read NAMESERVERS
echo -n "Введите search-name (Пример: ald.test): "
read SEARCH

systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl enable networking

cat <<EOL > /etc/network/interfaces
source /etc/network/interfaces.d/*


auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address $IPV4
netmask $MASK
gateway $GATEWAY
dns-nameservers $NAMESERVERS
dns-search $SEARCH
EOL

systemctl restart networking
apt update -y
apt upgrade -y

#Настройка /etc/hosts
cat <<EOL > /etc/hosts
127.0.0.1 localhost.localdomain localhost
$IPV4 $HOSTNAME $NAME
127.0.1.1 $NAME
EOL

#Настройка /etc/resolv.conf

cat <<EOL > /etc/resolv.conf
search $SEARCH
nameserver $NAMESERVERS
nameserver 8.8.8.8 
EOL

systemctl restart networking
#apt install ssh -y
#ssh-keygen -A
#systemctl restart ssh && systemctl enable ssh
DEBIAN_FRONTEND=noninteractive apt-get install -q -y aldpro-client
/opt/rbta/aldpro/client/bin/aldpro-client-installer -c $SEARCH -u admin -p QAZxsw123 -d $NAME -i -f

sleep 10
reboot

