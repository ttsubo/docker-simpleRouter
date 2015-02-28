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
	DISTRIB_DESCRIPTION="Ubuntu 14.04.2 LTS"

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
	Client version: 1.5.0
	Client API version: 1.17
	Go version (client): go1.4.1
	Git commit (client): a8a31ef
	OS/Arch (client): linux/amd64
	Server version: 1.5.0
	Server API version: 1.17
	Go version (server): go1.4.1
	Git commit (server): a8a31ef


### simple-routerイメージ作成
simple-routerイメージを作成します。

	$ sudo docker build -t simple-router --no-cache .
	Sending build context to Docker daemon 124.4 kB
	Sending build context to Docker daemon 
	Step 0 : FROM ubuntu:14.04.1
	 ---> 5ba9dab47459
	Step 1 : ENV DEBIAN_FRONTEND noninteractive
	 ---> Running in 309dbe745cb2
	 ---> b06b646eee0c
	Removing intermediate container 309dbe745cb2
	Step 2 : RUN apt-get update -y
	 ---> Running in 0e292e13f733

	(...snip)

	Step 22 : RUN git clone https://github.com/ttsubo/simpleRouter.git
	 ---> Running in bc144d1b7f7d
	Cloning into 'simpleRouter'...
	 ---> 2cab84911d97
	Removing intermediate container bc144d1b7f7d
	Successfully built 2cab84911d97


simple-routerイメージが作成されていれば、環境構築完了です。

	tsubo@Docker:~/docker-simpleRouter$ docker images
	REPOSITORY               TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
	simple-router            latest              2cab84911d97        2 minutes ago       848.6 MB
	ubuntu                   14.04               2d24f826cb16        7 days ago          188.3 MB
	ubuntu                   14.04.2             2d24f826cb16        7 days ago          188.3 MB
	ubuntu                   latest              2d24f826cb16        7 days ago          188.3 MB
	ubuntu                   trusty              2d24f826cb16        7 days ago          188.3 MB
	ubuntu                   trusty-20150218.1   2d24f826cb16        7 days ago          188.3 MB
	socketplane/docker-ovs   2.3.1               1395fc2eef47        2 weeks ago         33 MB
	ubuntu                   14.04.1             5ba9dab47459        4 weeks ago         188.3 MB


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
	98181aecd76d        ubuntu:14.04           "/bin/bash"         About a minute ago   Up About a minute                       pc2                 
	fe44e761d379        ubuntu:14.04           "/bin/bash"         About a minute ago   Up About a minute                       pc1                 
	c003539398c5        simple-router:latest   "/bin/bash"         3 minutes ago        Up 3 minutes                            GateSW2             
	aaa2c575ee7a        simple-router:latest   "/bin/bash"         3 minutes ago        Up 3 minutes                            GateSW1             
	69a9f425553e        simple-router:latest   "/bin/bash"         3 minutes ago        Up 3 minutes                            RyuBGP3             
	290ceecc0423        simple-router:latest   "/bin/bash"         3 minutes ago        Up 3 minutes                            RyuBGP2             
	8daa6e3852a5        simple-router:latest   "/bin/bash"         3 minutes ago        Up 3 minutes 

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
