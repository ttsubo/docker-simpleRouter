*** settings ***
Resource    Resources/change_med.robot
Resource    Resources/get_event.robot
Resource    Resources/get_rib.robot

*** Variables ***
${PEERIP}          192.168.101.102
${MED}             500
${myhost}          BGP4
${myport}          8084
${peerhost}        BGP1
${peerport}        8081
${check_med}       500
${expected_value}  OK

*** TestCases ***
(3-1) Change Med(500) in vrf(65010:101) in Router(BGP4)
    ${neighbor}=  Create Dictionary   peerIp=${PEERIP}
                  ...                 med=${MED}
    Change Med  ${neighbor}  ${myhost}  ${myport}

(3-2) Check previous med in RoutingTable in Peer Router(BGP1)
    Wait Until Keyword Succeeds  60s  10s
    ...  Check Rib_med information
    ...  ${peerhost}
    ...  ${peerport}
    ...  ${check_med}

(3-3) check reachability from pc1(192.168.1.102) to pc2(192.168.2.101)
    Sleep  30 seconds
    ${result}=  Get Event
    Sleep  10 seconds
    Should Be Equal As Strings  ${result}  ${expected_value}
