What's docker-simpleRouter (W.I.P.)
==========
Dockerコンテナ上で、Ryu/Lagopusを活用したOpenFlowルータを動作させることを目指します。

Environment
==========
Ubuntuサーバ上でDocker環境を構築します。
Lagopusについては、raw socket版での動作を想定しており、DPDK環境は構築しません。

	$ cat /etc/lsb-release 
	DISTRIB_ID=Ubuntu
	DISTRIB_RELEASE=14.04
	DISTRIB_CODENAME=trusty
	DISTRIB_DESCRIPTION="Ubuntu 14.04.1 LTS"

Installation
==========
### docker構築
docker-simpleRouterのファイル一式をダウンロードします。

	$ git clone https://github.com/ttsubo/docker-simpleRouter.git

dockerの実行環境を作成します

	$ ./simpleRouter.sh install

インストール後、 再ログインします。
(dockerグループへの所属を反映させるため)

dockerバージョン情報が正しく表示されることを確認します。

	$ docker version
	Client version: 1.3.2
	Client API version: 1.15
	Go version (client): go1.3.3
	Git commit (client): 39fa2fa
	OS/Arch (client): linux/amd64
	Server version: 1.3.2
	Server API version: 1.15
	Go version (server): go1.3.3
	Git commit (server): 39fa2fa


### simple-routerイメージ作成
simple-routerイメージを作成します。

	$ sudo docker build -t simple-router --no-cache .
	Sending build context to Docker daemon 25.09 kB
	Sending build context to Docker daemon 
	Step 0 : FROM ubuntu:14.04.1
	 ---> 5ba9dab47459
	Step 1 : ENV DEBIAN_FRONTEND noninteractive
	 ---> Running in 3da3a9872760
	 ---> a6e607d74051
	Removing intermediate container 3da3a9872760
	Step 2 : RUN apt-get update -y
	 ---> Running in 08cc8e2572fe

	(...snip)

	Step 17 : RUN git clone https://github.com/ttsubo/simpleRouter.git
	 ---> Running in e81dac2731cf
	Cloning into 'simpleRouter'...
	 ---> 52772eebafca
	Removing intermediate container e81dac2731cf
	Successfully built 52772eebafca


simple-routerイメージが作成されていれば、環境構築完了です。

	$ docker images
	REPOSITORY               TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
	simple-router            latest              52772eebafca        5 minutes ago       847.1 MB
	socketplane/docker-ovs   2.3.1               1395fc2eef47        13 days ago         33 MB
	osrg/ryu                 latest              d62adb7efd39        13 days ago         293.2 MB
	osrg/quagga              latest              0bbfdd10be15        3 weeks ago         245.7 MB
	ubuntu                   14.04               5ba9dab47459        3 weeks ago         188.3 MB
	ubuntu                   14.04.1             5ba9dab47459        3 weeks ago         188.3 MB
	ubuntu                   latest              5ba9dab47459        3 weeks ago         188.3 MB
	ubuntu                   trusty              5ba9dab47459        3 weeks ago         188.3 MB
 


Quick Start
===========
### simpleRouter起動
まずは、Dockerコンテナ作成や仮想ネットワーク構築します。
実際は、以下のコマンドを起動するのみです。

	$ ./simpleRouter.sh start
	0110b4a510ad9b5137005fa76ddfee3998d4a46b4e3327833a0519d0ff20076f
	f5a786112f4ebd42d52f919619524eedf96ea4e73434d6d078f6a0055c33eb55
	e490e8e7e580bc3f1309cf3e9c65aef651ab7d426533f0dfcae998dcf01a7d52
	2d298822b6439839b4a3a61758044af6ae71c8a449ceb08837b7cba776fdc982
	ad53e89896571dc5de39f7775061d482c564f1a73746fda3a3c535fbc878467b
	74aafd853d94440259ee054a6591fe6c1b5dbc528de0a76fae67d50ff33822ba
	24cc3598f51181dd24cce905b9ea35aaae664dbb1d8432e7c30eab13b6cf3726

起動処理が正しく完了すれば、計6個のLinixコンテナが作成されます。

	$ docker ps
	CONTAINER ID        IMAGE                  COMMAND             CREATED              STATUS              PORTS               NAMES
	24cc3598f511        ubuntu:14.04           "/bin/bash"         59 seconds ago       Up 59 seconds                           pc2                 
	74aafd853d94        ubuntu:14.04           "/bin/bash"         About a minute ago   Up 59 seconds                           pc1                 
	ad53e8989657        simple-router:latest   "/bin/bash"         About a minute ago   Up About a minute                       GateSW2             
	2d298822b643        simple-router:latest   "/bin/bash"         About a minute ago   Up About a minute                       GateSW1             
	e490e8e7e580        simple-router:latest   "/bin/bash"         About a minute ago   Up About a minute                       RyuBGP3             
	f5a786112f4e        simple-router:latest   "/bin/bash"         About a minute ago   Up About a minute                       RyuBGP2             
	0110b4a510ad        simple-router:latest   "/bin/bash"         About a minute ago   Up About a minute                       RyuBGP1

Dockerコンテナにアクセスしてみます。

	$ docker exec -it RyuBGP1 bash

Dockerコンテナ上で、Laopusを起動します。

	root@RyuBGP1:/root# ./start_lagopus.sh 

	root@RyuBGP1:/root# lagosh
	RyuBGP1> show flow
	Bridge: br0
	 Table id: 0
	
	RyuBGP1> show bridge-domains 
	bridge: br0
	  datapnath id: 0.00:00:00:00:00:01
	  max packet buffers: 65535, number of tables: 255
	  capabilities: flow_stats on, table_stats on, port_stats on, group_stats on
	                ip_reasm off, queue_stats on, port_blocked off
	  fail-mode: standalone-mode (default)
	port: eth1: ifindex 1, OpenFlow Port 1
	port: eth2: ifindex 2, OpenFlow Port 2
	port: eth3: ifindex 3, OpenFlow Port 3
	port: eth4: ifindex 4, OpenFlow Port 4
	port: eth5: ifindex 5, OpenFlow Port 5
	port: eth6: ifindex 6, OpenFlow Port 6
	
	RyuBGP1> show controller 127.0.0.1
	Controller 127.0.0.1
	 Datapath ID:       0000000000000001
	 Connection status: Disonnected

以降、Ryu-managerの起動手順および、simpleRouter設定手順は、こちらのURLの[Quick Start STEP3: Starting simpleRouter]と同じになります。
https://github.com/ttsubo/simpleRouter
