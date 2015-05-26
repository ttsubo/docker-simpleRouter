*** settings ***
Resource    Resources/create_route.robot
Resource    Resources/get_event.robot
Resource    Resources/get_rib.robot

*** Variables ***
${DESTINATION}     172.16.0.0
${NETMASK}         255.255.255.0
${NEXTHOP}         192.168.2.101
${VRF_ROUTEDIST}   65010:101
${myhost}          BGP6
${myport}          8086
${peerhost}        BGP4
${peerport}        8084
${check_prefix}    65010:101:172.16.0.0/24
${expected_value}  OK

*** TestCases ***
(1-1) Create prefix(172.16.0.0/24) in vrf(65010:101) in Router(BGP6)
    ${route}=  Create Dictionary   destination=${DESTINATION}
               ...                 netmask=${NETMASK}
               ...                 nexthop=${NEXTHOP}
               ...                 vrf_routeDist=${VRF_ROUTEDIST}
    Create Route  ${route}  ${myhost}  ${myport}

(1-2) Check previous prefix in RoutingTable in Peer Router(BGP4)
    Wait Until Keyword Succeeds  60s  10s
    ...  Check Rib_prefix information
    ...  ${peerhost}
    ...  ${peerport}
    ...  ${check_prefix}

(1-3) check reachability from pc1(192.168.1.102) to pc2(172.16.0.101)
    Sleep  30 seconds
    ${result}=  Get Event
    Sleep  10 seconds
    Should Be Equal As Strings  ${result}  ${expected_value}
