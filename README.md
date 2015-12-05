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
	Client:
	 Version:      1.9.1
	 API version:  1.21
	 Go version:   go1.4.3
	 Git commit:   a34a1d5
	 Built:        Fri Nov 20 17:56:04 UTC 2015
	 OS/Arch:      linux/amd64

	Server:
	 Version:      1.9.1
	 API version:  1.21
	 Go version:   go1.4.3
	 Git commit:   a34a1d5
	 Built:        Fri Nov 20 17:56:04 UTC 2015
	 OS/Arch:      linux/amd64


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
	REPOSITORY                  TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
	ubuntu                      14.04.3             ca4d7b1b9a51        3 weeks ago         187.9 MB
	ttsubo/simple-router        latest              6dc896a61946        4 weeks ago         1.032 GB
	ttsubo/test-server          latest              fa9be3b133b7        4 months ago        520.9 MB
	ttsubo/pc-term              latest              af1d34b3d434        7 months ago        253.7 MB


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
	CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS                     NAMES
	b53641af561e        ttsubo/test-server     "/bin/bash"         4 minutes ago       Up 4 minutes        0.0.0.0:10080->8080/tcp   TestServer
	c08e0fe06987        ttsubo/simple-router   "/bin/bash"         4 minutes ago       Up 4 minutes        0.0.0.0:8086->8080/tcp    BGP6
	e8d906bb14c7        ttsubo/simple-router   "/bin/bash"         4 minutes ago       Up 4 minutes        0.0.0.0:8085->8080/tcp    BGP5
	608dfdf65ca5        ttsubo/simple-router   "/bin/bash"         4 minutes ago       Up 4 minutes        0.0.0.0:8084->8080/tcp    BGP4
	abd9fb1ed9a7        ttsubo/simple-router   "/bin/bash"         4 minutes ago       Up 4 minutes        0.0.0.0:8083->8080/tcp    BGP3
	7344fc703e0e        ttsubo/simple-router   "/bin/bash"         4 minutes ago       Up 4 minutes        0.0.0.0:8082->8080/tcp    BGP2
	67fa79a2ffda        ttsubo/simple-router   "/bin/bash"         4 minutes ago       Up 4 minutes        0.0.0.0:8081->8080/tcp    BGP1
	b880b21d83cd        ttsubo/pc-term         "/bin/bash"         4 minutes ago       Up 4 minutes                                  pc2
	f6474039b496        ttsubo/pc-term         "/bin/bash"         4 minutes ago       Up 4 minutes



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
	64 bytes from 192.168.2.101: icmp_seq=1 ttl=64 time=29.5 ms
	64 bytes from 192.168.2.101: icmp_seq=2 ttl=64 time=21.3 ms
	64 bytes from 192.168.2.101: icmp_seq=3 ttl=64 time=36.1 ms
	64 bytes from 192.168.2.101: icmp_seq=4 ttl=64 time=34.8 ms
	64 bytes from 192.168.2.101: icmp_seq=5 ttl=64 time=24.1 ms
	^C
	--- 192.168.2.101 ping statistics ---
	5 packets transmitted, 5 received, 0% packet loss, time 4007ms
	rtt min/avg/max/mdev = 21.340/29.207/36.165/5.794 ms


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
	header: Date: Sat, 05 Dec 2015 05:47:11 GMT
	+++++++++++++++++++++++++++++++
	2015/12/05 05:47:11 : Show rib 
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
	Output:  /home/tsubo/docker-simpleRouter/Robot_Framework/output.xml
	Log:     /home/tsubo/docker-simpleRouter/Robot_Framework/log.html
	Report:  /home/tsubo/docker-simpleRouter/Robot_Framework/report.html


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
	Output:  /home/tsubo/docker-simpleRouter/Robot_Framework/output.xml
	Log:     /home/tsubo/docker-simpleRouter/Robot_Framework/log.html
	Report:  /home/tsubo/docker-simpleRouter/Robot_Framework/report.html


You can confirm test results automatically!!

### Checking Events as test results in TestServer
Let's check Events as test result of test1_create_route.robot.
You can confirm reachability from pc1(192.168.1.102) to pc2(172.16.0.101)

	$ docker exec -it TestServer bash

	root@TestServer:~# cd Test_automation/
	root@TestServer:~/Test_automation# cat Test_result.txt 
	2015/12/05 05:45:45 [1] [OK] [adj_rib_in_changed]
	2015/12/05 05:49:03 [2] [OK] [adj_rib_in_changed]
	2015/12/05 05:51:24 [3] [NG] [adj_rib_in_changed(withdraw)]

	root@TestServer:~/Test_automation# cd rest-client/
	root@TestServer:~/Test_automation/rest-client# ./get_event.sh 2

	-------------------------------------
	Event Infomation
	-------------------------------------
	event_id      [2]
	event_time    [2015/12/05 05:49:03]
	event_type    [adj_rib_in_changed]
	peer_bgp_id   [10.0.0.1]
	peer_as       [65010]
	received_time [2015/12/05 05:49:03]
	vpnv4_prefix  [65010:101:172.16.0.0/24]
	nexthop       [192.168.101.101]

	-------------------------------------
	Ping Result [OK]
	-------------------------------------
	$ ping -c 5 172.16.0.101 -I 192.168.1.102
	PING 172.16.0.101 (172.16.0.101) from 192.168.1.102 : 56(84) bytes of data.
	64 bytes from 172.16.0.101: icmp_seq=1 ttl=64 time=23.1 ms
	64 bytes from 172.16.0.101: icmp_seq=2 ttl=64 time=24.3 ms
	64 bytes from 172.16.0.101: icmp_seq=3 ttl=64 time=29.5 ms
	64 bytes from 172.16.0.101: icmp_seq=4 ttl=64 time=27.3 ms
	64 bytes from 172.16.0.101: icmp_seq=5 ttl=64 time=21.4 ms

	--- 172.16.0.101 ping statistics ---
	5 packets transmitted, 5 received, 0% packet loss, time 4008ms
	rtt min/avg/max/mdev = 21.498/25.187/29.582/2.922 ms


	-------------------------------------
	show Neighbor Result
	-------------------------------------
	bgpd> show neighbor received-routes 192.168.101.101 all
	Status codes: x filtered
	Origin codes: i - IGP, e - EGP, ? - incomplete
	    Timestamp           Network                          Labels   Next Hop             Metric LocPrf Path
	    2015/12/05 05:45:45 192.168.2.101/32                 None     192.168.101.101      100    None   [65010] ?
	    2015/12/05 05:49:03 172.16.0.0/24                    None     192.168.101.101      100    None   [65010] ?


	-------------------------------------
	show Rib Result
	-------------------------------------
	bgpd> show rib vpnv4
	Status codes: * valid, > best
	Origin codes: i - IGP, e - EGP, ? - incomplete
	     Network                          Labels   Next Hop             Reason          Metric LocPrf Path
	 *>  65010:101:192.168.2.101/32       [600]    192.168.101.101      Only Path       100           65010 ?
	 *>  65010:101:172.16.0.0/24          [601]    192.168.101.101      Only Path       100           65010 ?
	 *>  65010:101:192.168.1.102/32       [300]    192.168.105.102      Only Path              100    ?


Let's check Events as test result of test2_delete_route.robot.
You can confirm no reachability from pc1(192.168.1.102) to pc2(172.16.0.101)

	# ./get_event.sh 3

	-------------------------------------
	Event Infomation
	-------------------------------------
	event_id      [3]
	event_time    [2015/12/05 05:51:24]
	event_type    [adj_rib_in_changed(withdraw)]
	peer_bgp_id   [10.0.0.1]
	peer_as       [65010]
	received_time [2015/12/05 05:51:24]
	vpnv4_prefix  [65010:101:172.16.0.0/24]
	nexthop       [None]

	-------------------------------------
	Ping Result [NG]
	-------------------------------------
	$ ping -c 5 172.16.0.101 -I 192.168.1.102
	PING 172.16.0.101 (172.16.0.101) from 192.168.1.102 : 56(84) bytes of data.

	--- 172.16.0.101 ping statistics ---
	5 packets transmitted, 0 received, 100% packet loss, time 4031ms



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

