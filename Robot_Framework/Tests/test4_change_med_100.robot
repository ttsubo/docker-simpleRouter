*** settings ***
Resource    Resources/change_med.robot
Resource    Resources/get_event.robot
Resource    Resources/get_rib.robot

*** Variables ***
${PEERIP}          192.168.101.102
${MED}             100
${myhost}          BGP4
${myport}          8084
${peerhost}        BGP1
${peerport}        8081
${check_med}       100
${expected_value}  OK

*** TestCases ***
(4-1) Change Med(100) in vrf(65010:101) in Router(BGP4)
    ${neighbor}=  Create Dictionary   peerIp=${PEERIP}
                  ...                 med=${MED}
    Change Med  ${neighbor}  ${myhost}  ${myport}

(4-2) Check previous med in RoutingTable in Peer Router(BGP1)
    Wait Until Keyword Succeeds  60s  10s
    ...  Check Rib_med information
    ...  ${peerhost}
    ...  ${peerport}
    ...  ${check_med}

