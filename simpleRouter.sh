#!/bin/sh

check_user() {
    if [ `whoami` = "root" ]; then
        echo "Super user cannot execute! Please execute as non super user"
        exit 2
    fi
}

deploy_simpleRouter() {
    local host_name=$1
    local port_num=$2
    docker run --name $host_name --privileged -h $host_name -v $PWD/$1:/tmp -p $port_num:8080 -itd ttsubo/simple-router /bin/bash
    docker exec $host_name cp /tmp/OpenFlow.ini /root/simpleRouter/rest-client
    docker exec $host_name mkdir /usr/local/etc/lagopus
    docker exec $host_name cp /tmp/lagopus.dsl /usr/local/etc/lagopus
    docker exec $host_name cp /tmp/start_lagopus.sh /root
}

run_simpleRouter() {
    local host_name=$1
    docker exec $host_name echo "####################"
    docker exec $host_name echo "start $host_name ..."
    docker exec $host_name echo "####################"
    docker exec $host_name /root/start_lagopus.sh
    docker exec $host_name sleep 5
    docker exec $host_name bash -c "cd /root/simpleRouter/ryu-app && ryu-manager openflowRouter.py --log-config-file logging.conf" &
    docker exec $host_name sleep 5
    docker exec $host_name bash -c "cd /root/simpleRouter/rest-client && ./post_start_bgpspeaker.sh" > /dev/null
    docker exec $host_name sleep 5
    docker exec $host_name bash -c "cd /root/simpleRouter/rest-client && ./post_interface.sh" > /dev/null
    docker exec $host_name sleep 5
    docker exec $host_name bash -c "cd /root/simpleRouter/rest-client && ./post_vrf.sh" > /dev/null
    if [ $host_name = "BGP1" ]; then
        docker exec $host_name bash -c "cd /root/simpleRouter/rest-client && ./post_start_bmpclient.sh" > /dev/null
    fi
}

run_bgpSimulator() {
    local host_name=$1
    docker exec $host_name echo "####################"
    docker exec $host_name echo "start $host_name ..."
    docker exec $host_name echo "####################"
    docker exec $host_name bash -c "cd /root/ryu/bgpSimulator/ryu-app && ryu-manager bgpSimulator.py --log-config-file logging.conf" &
    docker exec $host_name sleep 5
    docker exec $host_name bash -c "cd /root/ryu/bgpSimulator/rest-client && ./post_start_bgpspeaker.sh" > /dev/null
    docker exec $host_name sleep 5
    docker exec $host_name bash -c "cd /root/ryu/bgpSimulator/rest-client && ./post_vrf.sh" > /dev/null
    docker exec $host_name sleep 5
    docker exec $host_name bash -c "cd /root/ryu/bgpSimulator/rest-client && ./post_interface.sh" > /dev/null

}

set_redistributeConnect() {
    local host_name=$1
    docker exec $host_name echo "#######################################"
    docker exec $host_name echo "set redistributeConnect($host_name) ..."
    docker exec $host_name echo "#######################################"
    docker exec $host_name bash -c "cd /root/simpleRouter/rest-client && ./post_redistributeConnect_on.sh" > /dev/null
}

deploy_bgpSimulator() {
    local host_name=$1
    docker run --name $host_name --privileged -h $host_name -p 10080:8080 -itd ttsubo/bgp-simulator /bin/bash
}

deploy_host() {
    local host_name=$1
    docker run --name $host_name --privileged -h $host_name -itd ttsubo/pc-term /bin/bash
    docker exec $host_name /etc/init.d/ssh start > /dev/null
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
        # deploy for pc1
        deploy_host pc1
        create_link br109 eth1 pc1 192.168.1.102/24@192.168.1.101
        create_link br10 eth2 pc1 192.168.0.7/24

        # deploy for pc2
        deploy_host pc2
        create_link br110 eth1 pc2 192.168.2.101/24@192.168.2.102
        create_link br111 eth2 pc2 172.16.0.101/24@192.168.2.102
        create_link br10 eth3 pc2 192.168.0.8/24

        # deploy for BGP1
        deploy_simpleRouter BGP1 8081
        create_link br101 eth1 BGP1 0.0.0.0/0
        create_link br104 eth2 BGP1 0.0.0.0/0
        create_link br105 eth3 BGP1 0.0.0.0/0

        create_link br301 eth4 BGP1 0.0.0.0/0
        create_link br204 eth5 BGP1 0.0.0.0/0
        create_link br205 eth6 BGP1 0.0.0.0/0

        create_link br301 eth7 BGP1 192.168.101.102/30 00:00:00:00:01:01
        create_link br204 eth8 BGP1 192.168.104.101/30 00:00:00:00:01:02
        create_link br205 eth9 BGP1 192.168.105.101/30 00:00:00:00:01:03
        create_link br10 eth10 BGP1 192.168.0.1/24

        # deploy for BGP2
        deploy_simpleRouter BGP2 8082
        create_link br102 eth1 BGP2 0.0.0.0/0
        create_link br104 eth2 BGP2 0.0.0.0/0
        create_link br106 eth3 BGP2 0.0.0.0/0

        create_link br302 eth4 BGP2 0.0.0.0/0
        create_link br304 eth5 BGP2 0.0.0.0/0
        create_link br206 eth6 BGP2 0.0.0.0/0

        create_link br302 eth7 BGP2 192.168.102.102/30 00:00:00:00:02:01
        create_link br304 eth8 BGP2 192.168.104.102/30 00:00:00:00:02:02
        create_link br206 eth9 BGP2 192.168.106.101/30 00:00:00:00:02:03
        create_link br10 eth10 BGP2 192.168.0.2/24

        # deploy for BGP3
        deploy_simpleRouter BGP3 8083
        create_link br105 eth1 BGP3 0.0.0.0/0
        create_link br106 eth2 BGP3 0.0.0.0/0
        create_link br109 eth3 BGP3 0.0.0.0/0

        create_link br305 eth4 BGP3 0.0.0.0/0
        create_link br306 eth5 BGP3 0.0.0.0/0

        create_link br305 eth6 BGP3 192.168.105.102/30 00:00:00:00:03:01
        create_link br306 eth7 BGP3 192.168.106.102/30 00:00:00:00:03:02
        create_link br10 eth8 BGP3 192.168.0.3/24

        # deploy for BGP4
        deploy_simpleRouter BGP4 8084
        create_link br101 eth1 BGP4 0.0.0.0/0
        create_link br103 eth2 BGP4 0.0.0.0/0
        create_link br107 eth3 BGP4 0.0.0.0/0

        create_link br201 eth4 BGP4 0.0.0.0/0
        create_link br203 eth5 BGP4 0.0.0.0/0
        create_link br307 eth6 BGP4 0.0.0.0/0

        create_link br201 eth7 BGP4 192.168.101.101/30 00:00:00:00:04:01
        create_link br203 eth8 BGP4 192.168.103.101/30 00:00:00:00:04:02
        create_link br307 eth9 BGP4 192.168.107.102/30 00:00:00:00:04:03
        create_link br10 eth10 BGP4 192.168.0.4/24

        # deploy for BGP5
        deploy_simpleRouter BGP5 8085
        create_link br102 eth1 BGP5 0.0.0.0/0
        create_link br103 eth2 BGP5 0.0.0.0/0
        create_link br108 eth3 BGP5 0.0.0.0/0

        create_link br202 eth4 BGP5 0.0.0.0/0
        create_link br303 eth5 BGP5 0.0.0.0/0
        create_link br308 eth6 BGP5 0.0.0.0/0

        create_link br202 eth7 BGP5 192.168.102.101/30 00:00:00:00:05:01
        create_link br303 eth8 BGP5 192.168.103.102/30 00:00:00:00:05:02
        create_link br308 eth9 BGP5 192.168.108.102/30 00:00:00:00:05:03
        create_link br10 eth10 BGP5 192.168.0.5/24

        # deploy for BGP6
        deploy_simpleRouter BGP6 8086
        create_link br107 eth1 BGP6 0.0.0.0/0
        create_link br108 eth2 BGP6 0.0.0.0/0
        create_link br110 eth3 BGP6 0.0.0.0/0

        create_link br207 eth4 BGP6 0.0.0.0/0
        create_link br208 eth5 BGP6 0.0.0.0/0

        create_link br207 eth6 BGP6 192.168.107.101/30 00:00:00:00:06:01
        create_link br208 eth7 BGP6 192.168.108.101/30 00:00:00:00:06:02
        create_link br10 eth8 BGP6 192.168.0.6/24

        # deploy for bgpSimulator
        deploy_bgpSimulator bgpSimulator
        create_link br10 eth1 bgpSimulator 192.168.0.100/24

        # run for simpleRouter
        run_simpleRouter BGP1
        run_simpleRouter BGP2
        run_simpleRouter BGP3
        run_simpleRouter BGP4
        run_simpleRouter BGP5
        run_simpleRouter BGP6
        sleep 30

        # run for bgpSimulator
        run_bgpSimulator bgpSimulator

        # set redistributeConnect
        set_redistributeConnect BGP3
        sleep 10
        set_redistributeConnect BGP6
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
	delete_bridge br109
	delete_bridge br110
	delete_bridge br201
	delete_bridge br202
	delete_bridge br203
	delete_bridge br204
	delete_bridge br205
	delete_bridge br206
	delete_bridge br207
	delete_bridge br208
	delete_bridge br301
	delete_bridge br302
	delete_bridge br303
	delete_bridge br304
	delete_bridge br305
	delete_bridge br306
	delete_bridge br307
	delete_bridge br308
	;;
    install)
        check_user
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
        sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
        sudo apt-get update
        sudo apt-get install -y --force-yes lxc-docker-1.7.0
        sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
        sudo gpasswd -a `whoami` docker
        sudo wget https://raw.github.com/jpetazzo/pipework/master/pipework -O /usr/local/bin/pipework
        sudo chmod 755 /usr/local/bin/pipework
        sudo apt-get install -y --force-yes iputils-arping bridge-utils tcpdump lv ethtool python
        sudo docker pull ubuntu:14.04.2
        sudo mkdir -p /var/run/netns
        ;;
    *)
        echo "Usage: ryu-docker-handson {start|stop|install}"
        exit 2
        ;;
esac
