#!/bin/sh

check_user() {
    if [ `whoami` = "root" ]; then
        echo "Super user cannot execute! Please execute as non super user"
        exit 2
    fi
}

deploy_simpleRouter() {
    local host_name=$1
    docker run --name $host_name --privileged -h $host_name -v $PWD/$1:/tmp -itd simple-router /bin/bash
    docker exec $host_name cp /tmp/OpenFlow.ini /root/simpleRouter/rest-client
    docker exec $host_name cp /tmp/lagopus.conf /usr/local/etc/lagopus
    docker exec $host_name cp /tmp/start_lagopus.sh /root
    if [ $host_name = "GateSW2" ]; then
        docker exec $host_name cp /tmp/post_interface.sh /root/simpleRouter/rest-client
    fi
}

run_host() {
    local host_name=$1
    docker run --name $host_name --privileged -h $host_name -itd ubuntu /bin/bash
}

delete_bridge() {
    local name=$1
    local sysfs_name=/sys/class/net/$name
    if [ -e $sysfs_name ]; then
	sudo ifconfig $name down
	sudo brctl delbr $name
    fi
}

create_link() {
    local bridge_name=$1
    local nic_name=$2
    local host_name=$3
    local ip_address=$4
    local mac_address=$5
    if [ $ip_address = "0.0.0.0/0" ]; then
        sudo pipework $bridge_name -i $nic_name $host_name $ip_address
    else
        sudo pipework $bridge_name -i $nic_name $host_name $ip_address $mac_address
    fi
}

case "$1" in
    start)
        # deploy for RyuBGP1
        deploy_simpleRouter RyuBGP1
        create_link br101 eth1 RyuBGP1 0.0.0.0/0
        create_link br104 eth2 RyuBGP1 0.0.0.0/0
        create_link br105 eth3 RyuBGP1 0.0.0.0/0

        create_link br301 eth4 RyuBGP1 0.0.0.0/0
        create_link br204 eth5 RyuBGP1 0.0.0.0/0
        create_link br205 eth6 RyuBGP1 0.0.0.0/0

        create_link br301 eth7 RyuBGP1 192.168.101.102/30 4a:6e:0e:de:27:54
        create_link br204 eth8 RyuBGP1 192.168.104.101/30 ea:65:4c:20:a0:0f
        create_link br205 eth9 RyuBGP1 192.168.105.101/30 fa:f4:2b:84:89:c4

        # deploy for RyuBGP2
        deploy_simpleRouter RyuBGP2
        create_link br102 eth1 RyuBGP2 0.0.0.0/0
        create_link br104 eth2 RyuBGP2 0.0.0.0/0
        create_link br106 eth3 RyuBGP2 0.0.0.0/0

        create_link br302 eth4 RyuBGP2 0.0.0.0/0
        create_link br304 eth5 RyuBGP2 0.0.0.0/0
        create_link br206 eth6 RyuBGP2 0.0.0.0/0

        create_link br302 eth7 RyuBGP2 192.168.102.102/30 5a:ae:88:4b:0a:3c
        create_link br304 eth8 RyuBGP2 192.168.104.102/30 ce:03:25:69:93:b7
        create_link br206 eth9 RyuBGP2 192.168.106.101/30 fe:bd:7e:9e:b3:0a

        # deploy for RyuBGP3
        deploy_simpleRouter RyuBGP3
        create_link br105 eth1 RyuBGP3 0.0.0.0/0
        create_link br106 eth2 RyuBGP3 0.0.0.0/0
        create_link br107 eth3 RyuBGP3 0.0.0.0/0

        create_link br305 eth4 RyuBGP3 0.0.0.0/0
        create_link br306 eth5 RyuBGP3 0.0.0.0/0

        create_link br305 eth6 RyuBGP3 192.168.105.102/30 ee:14:28:ab:49:77
        create_link br306 eth7 RyuBGP3 192.168.106.102/30 2a:04:c1:10:55:1e

        # deploy for GateSW1
        deploy_simpleRouter GateSW1
        create_link br101 eth1 GateSW1 0.0.0.0/0
        create_link br103 eth2 GateSW1 0.0.0.0/0
        create_link br100 eth3 GateSW1 0.0.0.0/0

        create_link br201 eth4 GateSW1 0.0.0.0/0
        create_link br203 eth5 GateSW1 0.0.0.0/0

        create_link br201 eth6 GateSW1 192.168.101.101/30 16:3f:1e:5b:32:c6
        create_link br203 eth7 GateSW1 192.168.103.101/30 66:1f:69:17:87:7a

        # deploy for GateSW2
        deploy_simpleRouter GateSW2
        create_link br102 eth1 GateSW2 0.0.0.0/0
        create_link br103 eth2 GateSW2 0.0.0.0/0

        create_link br202 eth3 GateSW2 0.0.0.0/0
        create_link br303 eth4 GateSW2 0.0.0.0/0

        create_link br202 eth5 GateSW2 192.168.102.101/30 0e:33:97:af:11:81
        create_link br303 eth6 GateSW2 192.168.103.102/30 ca:cd:2d:46:e4:e8

        # deploy for pc1
        run_host pc1
        create_link br107 eth1 pc1 192.168.100.1/24@192.168.100.101

        # deploy for pc2
        run_host pc2
        create_link br100 eth1 pc2 192.168.201.101/24@192.168.201.102

	;;
    stop)
	docker rm -f $(docker ps -qa)
	delete_bridge br100
	delete_bridge br101
	delete_bridge br102
	delete_bridge br103
	delete_bridge br104
	delete_bridge br105
	delete_bridge br106
	delete_bridge br107
	delete_bridge br108
	delete_bridge br201
	delete_bridge br202
	delete_bridge br203
	delete_bridge br204
	delete_bridge br205
	delete_bridge br206
	delete_bridge br301
	delete_bridge br302
	delete_bridge br303
	delete_bridge br304
	delete_bridge br305
	delete_bridge br306
	;;
    install)
        check_user
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
        sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
        sudo apt-get update
        sudo apt-get install -y --force-yes lxc-docker-1.3.2
        sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
        sudo gpasswd -a `whoami` docker
        sudo wget https://raw.github.com/jpetazzo/pipework/master/pipework -O /usr/local/bin/pipework
        sudo chmod 755 /usr/local/bin/pipework
        sudo apt-get install -y --force-yes iputils-arping bridge-utils tcpdump lv ethtool python
        sudo docker pull ubuntu:14.04.1
        sudo docker pull socketplane/docker-ovs:2.3.1
        sudo mkdir -p /var/run/netns
        ;;
    *)
        echo "Usage: ryu-docker-handson {start|stop|install}"
        exit 2
        ;;
esac
