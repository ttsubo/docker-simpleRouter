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
	$ git checkout TestAutomation
	$ git branch
	* TestAutomation
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


docker pull images for test-server

	$ docker pull ttsubo/test-server:latest
	(...snip)
	Status: Downloaded newer image for ttsubo/test-server:latest


### Checking Docker images
Checking the result of pulling docker images from Docker-Hub

	$ docker images
	REPOSITORY             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
	ubuntu                 14.04.2             6d4946999d4f        2 weeks ago         188.3 MB
	ttsubo/simple-router   latest              c821b66edd00        7 weeks ago         960.8 MB
	ttsubo/test-server     latest              b003817a7f6e        7 weeks ago         510 MB
	ttsubo/pc-term         latest              af1d34b3d434        7 weeks ago         253.7 MB


### install package for Robot Framework
You need to install some packages for Robot Framework

	$ sudo pip install robotframework
	$ sudo pip install robotframework-requests
	$ sudo pip install robotframework-sshlibrary
	$ sudo pip install requests

Robot Framework IDE (RIDE) is the integrated development environment to implement automated tests for the Robot Framework. 
At first, you need to install package for desktop environment.

	$ sudo pip install robotframework-ride
	$ sudo apt-get install python-wxgtk2.8


Quick Start
===========
### starting simpleRouter
You can start simpleRouter as bellow

	$ ./simpleRouter.sh start
	(...snip)


Checking running of container list

	$ docker ps
	CONTAINER ID        IMAGE                         COMMAND             CREATED             STATUS              PORTS                     NAMES
	3b455cf31971        ttsubo/test-server:latest     "/bin/bash"         3 minutes ago       Up 3 minutes        0.0.0.0:10080->8080/tcp   TestServer          
	b0bd88248ee8        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes        0.0.0.0:8086->8080/tcp    BGP6                
	daa2d1ba484b        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes        0.0.0.0:8085->8080/tcp    BGP5                
	f7e0ea2b9a5b        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes        0.0.0.0:8084->8080/tcp    BGP4                
	35dfe5046507        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes        0.0.0.0:8083->8080/tcp    BGP3                
	e9b9c5b95857        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes        0.0.0.0:8082->8080/tcp    BGP2                
	120a454e6ac3        ttsubo/simple-router:latest   "/bin/bash"         3 minutes ago       Up 3 minutes        0.0.0.0:8081->8080/tcp    BGP1                
	13c062d72e11        ttsubo/pc-term:latest         "/bin/bash"         3 minutes ago       Up 3 minutes                                  pc2                 
	3e4eaf915abd        ttsubo/pc-term:latest         "/bin/bash"         3 minutes ago       Up 3 minutes                                  pc1 



As a result, deploying virtual network for MPLS-VPN like this

                                                   TestServer
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
	64 bytes from 192.168.2.101: icmp_seq=1 ttl=64 time=41.9 ms
	64 bytes from 192.168.2.101: icmp_seq=2 ttl=64 time=32.2 ms
	64 bytes from 192.168.2.101: icmp_seq=3 ttl=64 time=31.4 ms
	64 bytes from 192.168.2.101: icmp_seq=4 ttl=64 time=33.5 ms
	64 bytes from 192.168.2.101: icmp_seq=5 ttl=64 time=43.4 ms
	^C
	--- 192.168.2.101 ping statistics ---
	5 packets transmitted, 5 received, 0% packet loss, time 4007ms
	rtt min/avg/max/mdev = 31.426/36.520/43.478/5.131 ms


For example, you can access container 'BGP3' for checking show-rib 

	$ docker exec -it BGP3 bash
	root@BGP3:~# cd simpleRouter/rest-client
	root@BGP3:~/simpleRouter/rest-client# ./get_rib.sh 
	======================================================================
	get_rib
	======================================================================
	/openflow/0000000000000001/rib
	----------
	reply: 'HTTP/1.1 200 OK\r\n'
	header: Content-Type: application/json; charset=UTF-8
	header: Content-Length: 459
	header: Date: Fri, 29 May 2015 22:50:54 GMT
	+++++++++++++++++++++++++++++++
	2015/05/29 22:50:54 : Show rib 
	+++++++++++++++++++++++++++++++
	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:192.168.1.102/32       [300]    0.0.0.0              Only Path                     ?
	 *>  65010:101:192.168.2.101/32       [600]    192.168.105.101      Only Path       100    100    65010 ?



It looks good!!


### Checking Test cases with Robot Framework
Let's try to start Test cases with Robot Framework.
First of all, create prefix in BGP6 ...

	$ cd Robot_Framework
	$ pybot Tests/test1_create_route.robot
	==============================================================================
	Test1 Create Route                                                            
	==============================================================================
	(1-1) Create prefix(172.16.0.0/24) in vrf(65010:101) in Router(BGP6)  | PASS |
	------------------------------------------------------------------------------
	(1-2) Check previous prefix in RoutingTable in Peer Router(BGP4)      | PASS |
	------------------------------------------------------------------------------
	(1-3) check reachability from pc1(192.168.1.102) to pc2(172.16.0.101) | PASS |
	------------------------------------------------------------------------------
	Test1 Create Route                                                    | PASS |
	3 critical tests, 3 passed, 0 failed
	3 tests total, 3 passed, 0 failed
	==============================================================================
	Output:  /home/tsubo/devel/docker-simpleRouter/Robot_Framework/output.xml
	Log:     /home/tsubo/devel/docker-simpleRouter/Robot_Framework/log.html
	Report:  /home/tsubo/devel/docker-simpleRouter/Robot_Framework/report.html


Secondary, delete prefix in BGP6 ...

	$ pybot Tests/test2_delete_route.robot 
	==============================================================================
	Test2 Delete Route                                                            
	==============================================================================
	(2-1) Delete prefix(172.16.0.0/24) in vrf(65010:101) in Router(BGP6)  | PASS |
	------------------------------------------------------------------------------
	(2-2) Check No previous prefix in RoutingTable in Peer Router(BGP4)   | PASS |
	------------------------------------------------------------------------------
	(2-3) check No reachability from pc1(192.168.1.102) to pc2(172.16.... | PASS |
	------------------------------------------------------------------------------
	Test2 Delete Route                                                    | PASS |
	3 critical tests, 3 passed, 0 failed
	3 tests total, 3 passed, 0 failed
	==============================================================================
	Output:  /home/tsubo/devel/docker-simpleRouter/Robot_Framework/output.xml
	Log:     /home/tsubo/devel/docker-simpleRouter/Robot_Framework/log.html
	Report:  /home/tsubo/devel/docker-simpleRouter/Robot_Framework/report.html


You can confirm test results automatically!!

### Checking Events as test results in TestServer
Let's check Events as test result of test1_create_route.robot.
You can confirm reachability from pc1(192.168.1.102) to pc2(172.16.0.101)

	$ docker exec -it TestServer bash
	root@TestServer:~# cd Test_automation/
	root@TestServer:~/Test_automation# cat Test_result.txt 
	2015/05/29 22:46:12 [1] [OK] [adj_rib_in_changed]
	2015/05/29 22:53:24 [2] [OK] [adj_rib_in_changed]
	2015/05/29 22:59:33 [3] [NG] [adj_rib_in_changed(withdraw)]

	root@TestServer:~/Test_automation# cd rest-client/
	root@TestServer:~/Test_automation/rest-client# ./get_event.sh 2
	/apgw/event

	{
	"event": {
	"event_id": "2"
	}
	}
	(51) accepted ('127.0.0.1', 56468)
	                                  127.0.0.1 - - [29/May/2015 23:04:25] "POST /apgw/event HTTP/1.1" 200 2035 0.000911
	                                    -------------------------------------
	Event Infomation
	-------------------------------------
	event_id      [2]
	event_time    [2015/05/29 22:53:24]
	event_type    [adj_rib_in_changed]
	peer_bgp_id   [10.0.0.1]
	peer_as       [65010]
	received_time [2015/05/29 22:53:23]
	vpnv4_prefix  [65010:101:172.16.0.0/24]
	nexthop       [192.168.101.101]

	-------------------------------------
	Ping Result [OK]
	-------------------------------------
	$ ping -c 5 172.16.0.101 -I 192.168.1.102
	PING 172.16.0.101 (172.16.0.101) from 192.168.1.102 : 56(84) bytes of data.
	64 bytes from 172.16.0.101: icmp_seq=1 ttl=64 time=29.6 ms
	64 bytes from 172.16.0.101: icmp_seq=2 ttl=64 time=31.6 ms
	64 bytes from 172.16.0.101: icmp_seq=3 ttl=64 time=31.2 ms
	64 bytes from 172.16.0.101: icmp_seq=4 ttl=64 time=35.2 ms
	64 bytes from 172.16.0.101: icmp_seq=5 ttl=64 time=37.8 ms

	--- 172.16.0.101 ping statistics ---
	5 packets transmitted, 5 received, 0% packet loss, time 4007ms
	rtt min/avg/max/mdev = 29.653/33.116/37.875/2.996 ms


	-------------------------------------
	show Neighbor Result
	-------------------------------------
	bgpd> show neighbor received-routes 192.168.101.101 all
	Status codes: x filtered
	Origin codes: i - IGP, e - EGP, ? - incomplete
	    Timestamp           Network                          Labels   Next Hop             Metric LocPrf Path
	    2015/05/29 22:46:12 192.168.2.101/32                 None     192.168.101.101      100    None   [65010] ?
	    2015/05/29 22:53:23 172.16.0.0/24                    None     192.168.101.101      100    None   [65010] ?


	-------------------------------------
	show Rib Result
	-------------------------------------
	bgpd> show rib vpnv4
	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:172.16.0.0/24          [601]    192.168.101.101      Only Path       100           65010 ?
	 *>  65010:101:192.168.2.101/32       [600]    192.168.101.101      Only Path       100           65010 ?
	 *>  65010:101:192.168.1.102/32       [300]    192.168.105.102      Only Path              100    ?


Let's check Events as test result of test2_delete_route.robot.
You can confirm no reachability from pc1(192.168.1.102) to pc2(172.16.0.101)

	# ./get_event.sh 3
	/apgw/event

	{
	"event": {
	"event_id": "3"
	}
	}
	(51) accepted ('127.0.0.1', 56469)
	                                  127.0.0.1 - - [29/May/2015 23:04:40] "POST /apgw/event HTTP/1.1" 200 1117 0.014948
	                                    -------------------------------------
	Event Infomation
	-------------------------------------
	event_id      [3]
	event_time    [2015/05/29 22:59:33]
	event_type    [adj_rib_in_changed(withdraw)]
	peer_bgp_id   [10.0.0.1]
	peer_as       [65010]
	received_time [2015/05/29 22:59:32]
	vpnv4_prefix  [65010:101:172.16.0.0/24]
	nexthop       [None]

	-------------------------------------
	Ping Result [NG]
	-------------------------------------
	$ ping -c 5 172.16.0.101 -I 192.168.1.102
	PING 172.16.0.101 (172.16.0.101) from 192.168.1.102 : 56(84) bytes of data.

	--- 172.16.0.101 ping statistics ---
	5 packets transmitted, 0 received, 100% packet loss, time 4002ms



	-------------------------------------
	show Neighbor Result
	-------------------------------------
	N/A

	-------------------------------------
	show Rib Result
	-------------------------------------
	bgpd> show rib vpnv4
	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:192.168.2.101/32       [600]    192.168.101.101      Only Path       100           65010 ?
	 *>  65010:101:192.168.1.102/32       [300]    192.168.105.102      Only Path              100    ?


It works fine!!


### stopping simpleRouter
You can stop simpleRouter as bellow

	$ ./simpleRouter.sh stop
	(...snip)

	$ docker ps
	CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS

