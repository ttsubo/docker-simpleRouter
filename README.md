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

Installation ...
(Needs for login again in Ubuntu after installation)

	$ cd docker-simpleRouter
	$ ./simpleRouter.sh install


Checking version in docker

	$ docker version
	Client version: 1.6.0
	Client API version: 1.18
	Go version (client): go1.4.2
	Git commit (client): 4749651
	OS/Arch (client): linux/amd64
	Server version: 1.6.0
	Server API version: 1.18
	Go version (server): go1.4.2
	Git commit (server): 4749651
	OS/Arch (server): linux/amd64


### download images from Docker-Hub
docker pull images for simple-router

	$ docker pull ttsubo/simple-router:latest

	(...snip)

	Digest: sha256:aecd207cc4390b345b6840db45099253edd4c8b8a8330ecee0ecd6f8a1f97c61
	Status: Downloaded newer image for ttsubo/simple-router:latest


docker pull images for pc-term

	$ docker pull ttsubo/pc-term:latest

	(...snip)

	Digest: sha256:6924f979906b3576ead6fff55020516f303e9fd83ba33d8d38f040cd9621ef7e
	Status: Downloaded newer image for ttsubo/pc-term:latest


docker pull images for test-server

	$ docker pull ttsubo/test-server:latest

	(...snip)

	Digest: sha256:0f916b800b4fae5bfa8973366588299cfeab75ceae628ed020adba225e146d90
	Status: Downloaded newer image for ttsubo/test-server:latest


### Checking Docker images
Checking the result of pulling docker images from Docker-Hub

	$ docker images
	REPOSITORY             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
	ttsubo/simple-router   latest              d713bbabb51a        16 hours ago        844.7 MB
	ttsubo/test-server     latest              fc3db66f9ef8        18 hours ago        506.8 MB
	ttsubo/pc-term         latest              7559c9022200        19 hours ago        253.6 MB
	ubuntu                 14.04.2             07f8e8c5e660        5 days ago          188.3 MB
	ubuntu                 latest              2d24f826cb16        10 weeks ago        188.3 MB
	ubuntu                 trusty              2d24f826cb16        10 weeks ago        188.3 MB
	ubuntu                 14.04               2d24f826cb16        10 weeks ago        188.3 MB


Quick Start
===========
### starting simpleRouter
You can start simpleRouter as bellow

	$ ./simpleRouter.sh start

	(...snip)


Checking running of container list

	$ docker ps
	CONTAINER ID        IMAGE                         COMMAND             CREATED             STATUS              PORTS               NAMES
	83ca02f1ecd4        ttsubo/test-server:latest     "/bin/bash"         3 minutes ago       Up 3 minutes                            TestServer          
	2982484362ff        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes                            BGP6                
	2bf515eef6aa        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes                            BGP5                
	f0bd99926779        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes                            BGP4                
	c443fd79f7af        ttsubo/simple-router:latest   "/bin/bash"         4 minutes ago       Up 4 minutes                            BGP3                
	0e7ed5c3f0be        ttsubo/simple-router:latest   "/bin/bash"         4 minutes ago       Up 4 minutes                            BGP2                
	da71da029ef4        ttsubo/simple-router:latest   "/bin/bash"         4 minutes ago       Up 4 minutes                            BGP1                
	524d64c747f9        ttsubo/pc-term:latest         "/bin/bash"         4 minutes ago       Up 4 minutes                            pc2                 
	1937648967a2        ttsubo/pc-term:latest         "/bin/bash"         4 minutes ago       Up 4 minutes                            pc1                 



As a result, deploying virtual network for MPLS-VPN like this

          (192.168.2.101)                                    (192.168.1.102)
            ↓                                                ↓
           pc2 ---- BGP6 ---- BGP4 ---- BGP1 ---- BGP3 ---- pc1
                     |         |         |         |
                     \------- BGP5 ---- BGP2 ------/


### Accessing ... after starting simpleRouter
For example, you can access container 'pc1' for executing ping from pc1 to pc2

	$ docker exec -it pc1 bash
	root@pc1:/# ping 192.168.2.101
	PING 192.168.2.101 (192.168.2.101) 56(84) bytes of data.
	64 bytes from 192.168.2.101: icmp_seq=1 ttl=64 time=59.7 ms
	64 bytes from 192.168.2.101: icmp_seq=2 ttl=64 time=49.1 ms
	64 bytes from 192.168.2.101: icmp_seq=3 ttl=64 time=44.4 ms
	64 bytes from 192.168.2.101: icmp_seq=4 ttl=64 time=28.4 ms
	64 bytes from 192.168.2.101: icmp_seq=5 ttl=64 time=39.0 ms
	64 bytes from 192.168.2.101: icmp_seq=6 ttl=64 time=49.6 ms
	^C
	--- 192.168.2.101 ping statistics ---
	6 packets transmitted, 6 received, 0% packet loss, time 5009ms
	rtt min/avg/max/mdev = 28.449/45.082/59.703/9.698 ms


For example, you can access container 'BGP3' for checking show-rib 

	$ docker exec -it BGP3 bash
	root@BGP3:~# cd simpleRouter/rest-client/
	root@BGP3:~/simpleRouter/rest-client# ./get_rib.sh 
	======================================================================
	get_rib
	======================================================================
	/openflow/0000000000000001/rib
	----------
	reply: 'HTTP/1.1 200 OK\r\n'
	header: Content-Type: application/json; charset=UTF-8
	header: Content-Length: 459
	header: Date: Wed, 06 May 2015 01:23:17 GMT
	+++++++++++++++++++++++++++++++
	2015/05/06 01:23:17 : Show rib 
	+++++++++++++++++++++++++++++++
	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:192.168.2.101/32       [600]    192.168.105.101      Only Path       100    100    65010 ?
	 *>  65010:101:192.168.1.102/32       [300]    0.0.0.0              Only Path                     ?


It looks good!!


### stopping simpleRouter
You can stop simpleRouter as bellow

	$ ./simpleRouter.sh stop

	(...snip)

	$ docker ps
	CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS

