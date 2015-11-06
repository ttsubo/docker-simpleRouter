channel channel01 create -dst-addr 127.0.0.1 -protocol tcp

controller controller01 create -channel channel01 -connection-type main

interface interface01 create -type ethernet-rawsock -device eth1 -port-number 1
interface interface02 create -type ethernet-rawsock -device eth2 -port-number 2
interface interface03 create -type ethernet-rawsock -device eth3 -port-number 3
interface interface04 create -type ethernet-rawsock -device eth4 -port-number 4
interface interface05 create -type ethernet-rawsock -device eth5 -port-number 5
interface interface06 create -type ethernet-rawsock -device eth6 -port-number 6

port port01 create -interface interface01
port port02 create -interface interface02
port port03 create -interface interface03
port port04 create -interface interface04
port port05 create -interface interface05
port port06 create -interface interface06

bridge bridge01 create -controller controller01 -port port01 1 -port port02 2 -port port03 3 -port port04 4 -port port05 5 -port port06 6 -dpid 0x1
bridge bridge01 enable
