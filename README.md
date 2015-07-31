What's docker-simpleRouter
==========
docker-simpleRouter is a software router based RyuBGP with LagopusSwitch. 
It works as a openflow controller supporting mpBGP/MPLS-VPN in Docker-container.

### deploying virtual network in Docker-container 
You can deploy virtual networks as MPLS-VPN as bellow. 
(not including OSPF/LDP protocols in simpleRouter)

     pc2 ---- BGP6 ---- BGP4 ---- BGP1 ---- BGP3 ---- pc1
               |         |         |         |
               \------- BGP5 ---- BGP2 ------/

              < AS65010 >        < AS65011 >

Environment
==========
It recommends for using Ubuntu Server Edition.
LagopusSwitch has not been installed DPDK environment in simpleRouter.
Therefore, LagopusSwitch works as Raw-socket edition

	$ cat /etc/lsb-release 
	DISTRIB_ID=Ubuntu
	DISTRIB_RELEASE=14.04
	DISTRIB_CODENAME=trusty
	DISTRIB_DESCRIPTION="Ubuntu 14.04.2 LTS"

Installation
==========
### install of docker-simpleRouter
Get the Docker-simpleRouter code from github

	$ git clone https://github.com/ttsubo/docker-simpleRouter.git
	$ cd docker-simpleRouter
	$ git checkout bgpSimulator
	$ git branch
	  TestAutomation
	* bgpSimulator
	  master

Installation ...
(Needs for login again in Ubuntu after installation)

	$ ./simpleRouter.sh install


Checking version in docker

	$ docker version
	Client version: 1.7.0
	Client API version: 1.19
	Go version (client): go1.4.2
	Git commit (client): 0baf609
	OS/Arch (client): linux/amd64
	Server version: 1.7.0
	Server API version: 1.19
	Go version (server): go1.4.2
	Git commit (server): 0baf609
	OS/Arch (server): linux/amd64


### download images from Docker-Hub
docker pull images for simple-router

	$ docker pull ttsubo/simple-router:latest
	(...snip)
	Status: Downloaded newer image for ttsubo/simple-router:latest


docker pull images for pc-term

	$ docker pull ttsubo/pc-term:latest
	(...snip)
	Status: Downloaded newer image for ttsubo/pc-term:latest


docker pull images for bgp-simulator

	$ docker pull ttsubo/bgp-simulator:latest
	(...snip)
	Status: Downloaded newer image for ttsubo/bgp-simulator


### Checking Docker images
Checking the result of pulling docker images from Docker-Hub

	$ docker images
	REPOSITORY             TAG                 IMAGE ID            CREATED                  VIRTUAL SIZE
	ttsubo/bgp-simulator   latest              14a8a6093a9c        Less than a second ago   521.5 MB
	ttsubo/simple-router   latest              be8a615a3c97        14 hours ago             853.3 MB
	ttsubo/test-server     latest              fa9be3b133b7        13 days ago              520.9 MB
	ttsubo/pc-term         latest              af1d34b3d434        12 weeks ago             253.7 MB



Quick Start
===========
### starting simpleRouter
You can start simpleRouter as bellow

	$ ./simpleRouter.sh start
	(...snip)


Checking running of container list

	$ docker ps
	CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS                     NAMES
	9d49d14b1a68        ttsubo/bgp-simulator   "/bin/bash"         12 seconds ago      Up 11 seconds       0.0.0.0:10080->8080/tcp   bgpSimulator        
	993fac2b0ceb        ttsubo/simple-router   "/bin/bash"         15 seconds ago      Up 14 seconds       0.0.0.0:8086->8080/tcp    BGP6                
	a58fea14af5b        ttsubo/simple-router   "/bin/bash"         18 seconds ago      Up 17 seconds       0.0.0.0:8085->8080/tcp    BGP5                
	b167b6dd1680        ttsubo/simple-router   "/bin/bash"         21 seconds ago      Up 20 seconds       0.0.0.0:8084->8080/tcp    BGP4                
	7ff40a1451db        ttsubo/simple-router   "/bin/bash"         23 seconds ago      Up 22 seconds       0.0.0.0:8083->8080/tcp    BGP3                
	2ca5f98776e6        ttsubo/simple-router   "/bin/bash"         26 seconds ago      Up 25 seconds       0.0.0.0:8082->8080/tcp    BGP2                
	208b694e4220        ttsubo/simple-router   "/bin/bash"         29 seconds ago      Up 28 seconds       0.0.0.0:8081->8080/tcp    BGP1                
	e186f665694b        ttsubo/pc-term         "/bin/bash"         30 seconds ago      Up 29 seconds                                 pc2                 
	cc789e7337cb        ttsubo/pc-term         "/bin/bash"         34 seconds ago      Up 32 seconds                                 pc1



As a result, deploying virtual network for MPLS-VPN like this

                                                   bgpSimulator
                                                       ↑
                                                       ↑
                                                       ↑ (bmp)
                        (192.168.2.101)                ↑                   (192.168.1.102)
                          ↓                            ↑                   ↓
        (172.16.0.0/24)→ pc2 ---- BGP6 ---- BGP4 ---- BGP1 ---- BGP3 ---- pc1
                                   |         |         |         |
                                   \------- BGP5 ---- BGP2 ------/


### Accessing ... after starting simpleRouter
For example, you can access container 'pc1' for executing ping from pc1 to pc2

	$ docker exec -it pc1 bash
	PING 192.168.2.101 (192.168.2.101) 56(84) bytes of data.
	64 bytes from 192.168.2.101: icmp_seq=1 ttl=64 time=36.4 ms
	64 bytes from 192.168.2.101: icmp_seq=2 ttl=64 time=37.7 ms
	64 bytes from 192.168.2.101: icmp_seq=3 ttl=64 time=35.0 ms
	64 bytes from 192.168.2.101: icmp_seq=4 ttl=64 time=37.1 ms
	64 bytes from 192.168.2.101: icmp_seq=5 ttl=64 time=30.5 ms
	^C
	--- 192.168.2.101 ping statistics ---
	5 packets transmitted, 5 received, 0% packet loss, time 4009ms
	rtt min/avg/max/mdev = 30.533/35.383/37.781/2.593 ms


For example, you can access container 'BGP1' for checking show-rib 

	$ docker exec -it BGP1 bash
	root@BGP1:~# cd simpleRouter/rest-client
	root@BGP1:~/simpleRouter/rest-client# ./get_rib.sh 
	======================================================================
	get_rib
	======================================================================
	/openflow/0000000000000001/rib
	----------
	reply: 'HTTP/1.1 200 OK\r\n'
	header: Content-Type: application/json; charset=UTF-8
	header: Content-Length: 459
	header: Date: Fri, 31 Jul 2015 18:26:05 GMT
	+++++++++++++++++++++++++++++++
	2015/07/31 18:26:05 : Show rib 
	+++++++++++++++++++++++++++++++
	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:192.168.2.101/32       [600]    192.168.101.101      Only Path       100           65010 ?
	 *>  65010:101:192.168.1.102/32       [300]    192.168.105.102      Only Path              100    ?


It looks good!!


### Checking show-rib in bgpSimulator

You can access container 'bgpSimulator' for checking show-rib 

	$ docker exec -it bgpSimulator bash
	root@bgpSimulator:~/ryu/bgpSimulator# cd rest-client/
	root@bgpSimulator:~/ryu/bgpSimulator/rest-client# ./get_rib.sh 
	======================================================================
	get_rib
	======================================================================
	/openflow/0000000000000001/rib
	----------
	reply: 'HTTP/1.1 200 OK\r\n'
	header: Content-Type: application/json; charset=UTF-8
	header: Content-Length: 459
	header: Date: Fri, 31 Jul 2015 18:32:26 GMT
	+++++++++++++++++++++++++++++++
	2015/07/31 18:32:26 : Show rib 
	+++++++++++++++++++++++++++++++
	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:192.168.2.101/32       [600]    192.168.101.101      Only Path       100           65010 ?
	 *>  65010:101:192.168.1.102/32       [300]    192.168.105.102      Only Path              100    ?

It looks the bgpSimulator works fine as BGP Monitoring tool. 
These RIBs are synchronized between BGP1 and bgpSimulator through bmp messages. 

### stopping simpleRouter
You can stop simpleRouter as bellow

	$ ./simpleRouter.sh stop
	(...snip)

	$ docker ps
	CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS

