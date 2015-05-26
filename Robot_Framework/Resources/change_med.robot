*** settings ***
Library     Lib.conversions
Library     RequestsLibrary
Library     Collections


*** Keywords ***
Change Med
    [Arguments]  ${neighbor}  ${host}  ${port}
    ${headers}=  Create Dictionary  Content-Type=application/json
    Create Session  ${host}  http://127.0.0.1:${port}  ${headers}
    ${data}=  Create Dictionary   neighbor=${neighbor}
    ${data}=  Get Json From Dict  ${data}
    ${result} =  Put  ${host}  /openflow/0000000000000001/neighbor  ${data}
    Log     ${result.status_code}
    Log     ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200
