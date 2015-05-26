*** settings ***
Library     Lib.conversions
Library     RequestsLibrary
Library     Collections

*** Keywords ***
Get Event
    ${headers}=  Create Dictionary  Content-Type=application/json
    Create Session  TestServer  http://127.0.0.1:10080  ${headers}
    ${result} =  Get  TestServer  /apgw/event/latest
    Log     ${result.json()['event']['ping_result']}
    Log     ${result.json()['event']['ping_recv']}
    Should Be Equal As Strings  ${result.status_code}  200
    [return]  ${result.json()['event']['ping_result']}
