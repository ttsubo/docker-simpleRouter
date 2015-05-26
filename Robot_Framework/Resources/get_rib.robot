*** settings ***
Library     RequestsLibrary
Library     Collections

*** Keywords ***
Get Rib
    [Arguments]  ${host}  ${port}
    ${headers}=  Create Dictionary  Content-Type=application/json
    Create Session  ${host}  http://127.0.0.1:${port}  ${headers}
    ${result} =  Get Request  ${host}  /openflow/0000000000000001/rib
    Log     ${result.status_code}
    Log     ${result.json()['rib']}
    Should Be Equal As Strings  ${result.status_code}  200
    [return]  ${result.json()['rib']}

Check Rib_med information
    [Arguments]  ${host}  ${port}  ${check_med}
    ${result}=  Get Rib  ${host}  ${port}
    Should Contain  ${result}  ${check_med}

Check Rib_prefix information
    [Arguments]  ${host}  ${port}  ${check_prefix}
    ${result}=  Get Rib  ${host}  ${port}
    Should Contain  ${result}  ${check_prefix}

Check Rib_no_prefix information
    [Arguments]  ${host}  ${port}  ${check_prefix}
    ${result}=  Get Rib  ${host}  ${port}
    Should Not Contain  ${result}  ${check_prefix}
