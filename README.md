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
	DISTRIB_DESCRIPTION="Ubuntu 14.04.3 LTS"

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
	REPOSITORY                  TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
	ttsubo/bgp-simulator        latest              ad02723a40cf        40 seconds ago      524.1 MB
	ttsubo/simple-router        latest              6dc896a61946        3 weeks ago         1.032 GB
	ubuntu                      14.04.3             91e54dfb1179        3 months ago        188.4 MB
	ttsubo/test-server          latest              fa9be3b133b7        4 months ago        520.9 MB
	ttsubo/pc-term              latest              af1d34b3d434        7 months ago        253.7 MB



Quick Start
===========
### starting simpleRouter
You can start simpleRouter as bellow

	$ ./simpleRouter.sh start
	(...snip)


Checking running of container list

	$ docker ps
	CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS                     NAMES
	47631c1eb43c        ttsubo/bgp-simulator   "/bin/bash"         6 seconds ago       Up 5 seconds        0.0.0.0:10080->8080/tcp   bgpSimulator        
	a7b3eb19cf98        ttsubo/simple-router   "/bin/bash"         10 seconds ago      Up 9 seconds        0.0.0.0:8086->8080/tcp    BGP6                
	ea5d4d809665        ttsubo/simple-router   "/bin/bash"         15 seconds ago      Up 15 seconds       0.0.0.0:8085->8080/tcp    BGP5                
	0b03bcbd60e5        ttsubo/simple-router   "/bin/bash"         21 seconds ago      Up 20 seconds       0.0.0.0:8084->8080/tcp    BGP4                
	8903c2be679e        ttsubo/simple-router   "/bin/bash"         25 seconds ago      Up 24 seconds       0.0.0.0:8083->8080/tcp    BGP3                
	e10ec48d9f40        ttsubo/simple-router   "/bin/bash"         30 seconds ago      Up 29 seconds       0.0.0.0:8082->8080/tcp    BGP2                
	8c3f0b927fd3        ttsubo/simple-router   "/bin/bash"         36 seconds ago      Up 35 seconds       0.0.0.0:8081->8080/tcp    BGP1                
	484e4fa03b6b        ttsubo/pc-term         "/bin/bash"         39 seconds ago      Up 38 seconds                                 pc2                 
	58d7a7bb2268        ttsubo/pc-term         "/bin/bash"         45 seconds ago      Up 44 seconds                                 pc1 


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

	root@pc1:/# ping 192.168.2.101
	PING 192.168.2.101 (192.168.2.101) 56(84) bytes of data.
	64 bytes from 192.168.2.101: icmp_seq=1 ttl=64 time=21.7 ms
	64 bytes from 192.168.2.101: icmp_seq=2 ttl=64 time=20.1 ms
	64 bytes from 192.168.2.101: icmp_seq=3 ttl=64 time=28.5 ms
	64 bytes from 192.168.2.101: icmp_seq=4 ttl=64 time=21.5 ms
	64 bytes from 192.168.2.101: icmp_seq=5 ttl=64 time=22.8 ms
	^C
	--- 192.168.2.101 ping statistics ---
	5 packets transmitted, 5 received, 0% packet loss, time 4001ms
	rtt min/avg/max/mdev = 20.170/22.937/28.504/2.911 ms


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
	header: Date: Fri, 04 Dec 2015 04:30:49 GMT
	+++++++++++++++++++++++++++++++
	2015/12/04 04:30:49 : Show rib 
	+++++++++++++++++++++++++++++++
	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:192.168.2.101/32       [600]    192.168.101.101      Only Path       100           65010 ?
	 *>  65010:101:192.168.1.102/32       [300]    192.168.105.102      Only Path 


It looks good!!


### Checking show-rib in bgpSimulator

You can access container 'bgpSimulator' for checking show-rib 

	$ docker exec -it bgpSimulator bash

	root@bgpSimulator:~/ryu/bgpSimulator# cd rest-client/
	root@bgpSimulator:~/ryu/bgpSimulator/rest-client# ./get_rib.sh

	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:192.168.1.102/32       [300]    192.168.105.102      Only Path              100    ?
	 *>  65010:101:192.168.2.101/32       [600]    192.168.101.101      Only Path       100           65010 ?


It looks the bgpSimulator works fine as BGP Monitoring tool. 
These RIBs are synchronized between BGP1 and bgpSimulator through bmp messages. 

### stopping simpleRouter
You can stop simpleRouter as bellow

	$ ./simpleRouter.sh stop
	(...snip)

	$ docker ps
	CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS

