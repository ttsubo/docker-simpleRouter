*** settings ***
Library     Lib.conversions
Library     RequestsLibrary
Library     Collections


*** Keywords ***
Delete Route
    [Arguments]  ${route}  ${host}  ${port}
    ${headers}=  Create Dictionary  Content-Type=application/json
    Create Session  ${host}  http://127.0.0.1:${port}  ${headers}
    ${data}=  Create Dictionary   route=${route}
    ${data}=  Get Json From Dict  ${data}
    ${result} =  Delete  ${host}  /openflow/0000000000000001/route  ${data}
    Log     ${result.status_code}
    Log     ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200
