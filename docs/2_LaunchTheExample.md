# Launch The Example

To launch your tests, enter this command.

```bash
afb-daemon --name afbd-test --port=1234 --workdir=package --ldpaths=/opt/AGL/lib64/afb:lib --token= -vvv --tracereq=common
```

On afb-daemon startup you should have all the app-framework config displayed:

```shell
---BEGIN-OF-CONFIG---
--         console: ./AFB-console.out
--         rootdir: .
--        roothttp:
--        rootbase: /opa
--         rootapi: /api
--         workdir: .
--       uploaddir: .
--           token: 1
--            name: afbd-test
--         aliases:
--    dbus_clients:
--    dbus_servers:
--      ws_clients:
--      ws_servers:
--     so_bindings:
--         ldpaths: /opt/AGL/lib64/afb:lib
--    weak_ldpaths:
--           calls:
--            exec:
--       httpdPort: 1234
--    cacheTimeout: 100000
--      apiTimeout: 20
--     cntxTimeout: 32000000
--    nbSessionMax: 10
--            mode: local
--        tracereq: common
--       traceditf: no
--        tracesvc: no
--        traceevt: no
--      no_ldpaths: no
--         noHttpd: no
--      background: no
--      monitoring: no
--    random_token: no
---END-OF-CONFIG---
INFO: entering foreground mode
INFO: running with pid 20430
INFO: API monitor added
INFO: binding monitor added to set main
INFO: Scanning dir=[/opt/AGL/lib64/afb] for bindings
INFO: binding [/opt/AGL/lib64/afb/demoContext.so] is a valid AFB binding V1
INFO: binding [/opt/AGL/lib64/afb/demoContext.so] calling registering function afbBindingV1Register
INFO: API context added
INFO: binding /opt/AGL/lib64/afb/demoContext.so loaded with API prefix context
INFO: binding [/opt/AGL/lib64/afb/helloWorld.so] looks like an AFB binding V2
INFO: binding hello calling preinit function
NOTICE: [API hello] hello binding comes to live
INFO: API hello added
INFO: binding hello added to set main
INFO: binding [/opt/AGL/lib64/afb/tic-tac-toe.so] looks like an AFB binding V2
INFO: API tictactoe added
INFO: binding tictactoe added to set main
INFO: binding [/opt/AGL/lib64/afb/demoPost.so] is a valid AFB binding V1
INFO: binding [/opt/AGL/lib64/afb/demoPost.so] calling registering function afbBindingV1Register
INFO: API post added
INFO: binding /opt/AGL/lib64/afb/demoPost.so loaded with API prefix post
INFO: binding [/opt/AGL/lib64/afb/ave.so] looks like an AFB binding Vdyn
...
...
...
NOTICE: API salut started
INFO: API tictactoe starting...
NOTICE: API tictactoe started
NOTICE: Waiting port=1234 rootdir=.
NOTICE: Browser URL= http://localhost:1234
```

Then in a new terminal launch the client:

``` bash
afb-client-demo ws://localhost:1234/api?token=1
afTest launch_all_tests
```

You should get something like:

``` bash
{"response":{"info":"Launching tests"},"jtype":"afb-reply","request":{"status":"success","uuid":"3fa17ce6-0029-4ef9-8e0d-38dba2a9cf38"}}
{"event":"afTest\/results","data":{"info":"Success : 72 Failures : 6"},"jtype":"afb-event"}
```

Here you can see that the verb succeeded and that we have 71 Success for 5 failures.

And on your afb-daemon terminal you have all information about your tests step-by-step (note that it depends on the level of verbosity you gave to the afb-daemon (-vvv option)).

```shell
DEBUG: received websocket request for afTest/launch_all_tests: null
HOOK: [xreq-000001:afTest/launch_all_tests] BEGIN
HOOK: [xreq-000001:afTest/launch_all_tests] json() -> "null"
HOOK: [xreq-000002:monitor/set] BEGIN
HOOK: [xreq-000002:monitor/set] reply[denied](null, invalid token's identity)
HOOK: [xreq-000002:monitor/set] END
HOOK: [xreq-000003:monitor/trace] BEGIN
HOOK: [xreq-000003:monitor/trace] reply[denied](null, invalid token's identity)
HOOK: [xreq-000003:monitor/trace] END
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
...
...
...
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~~~~~~ BEGIN ALL TESTS ~~~~~~~~~~
HOOK: [xreq-000001:afTest/launch_all_tests] reply[success]({ "info": "Launching tests" }, (null))
# XML output to var/jUnitResults.xml
# Started on Wed Jul 11 15:42:44 2018
# Starting class: testPingSuccess
# Starting test: testPingSuccess.testFunction
~~~~~ Begin testPingSuccess ~~~~~
HOOK: [xreq-000004:hello/ping] BEGIN
HOOK: [xreq-000004:hello/ping] json() -> null
HOOK: [xreq-000004:hello/ping] reply[success]("Some String", Ping Binder Daemon tag=pingSample count=1 query=null)
HOOK: [xreq-000004:hello/ping] END
~~~~~ End testPingSuccess ~~~~~
# Starting class: testPingSuccessAndResponse
# Starting test: testPingSuccessAndResponse.testFunction
HOOK: [xreq-000005:hello/ping] BEGIN
HOOK: [xreq-000005:hello/ping] json() -> null
HOOK: [xreq-000005:hello/ping] reply[success]("Some String", Ping Binder Daemon tag=pingSample count=2 query=null)
HOOK: [xreq-000005:hello/ping] END
# Starting class: testPingSuccessResponseFail
# Starting test: testPingSuccessResponseFail.testFunction
HOOK: [xreq-000006:hello/ping] BEGIN
HOOK: [xreq-000006:hello/ping] json() -> null
HOOK: [xreq-000006:hello/ping] reply[success]("Some String", Ping Binder Daemon tag=pingSample count=3 query=null)
HOOK: [xreq-000006:hello/ping] END
#   Failure:  ./var/aft.lua:224: expected: "Unexpected String"
#   actual: "Some String"
...
...
...
~~~~~~~~~~ END ALL TESTS ~~~~~~~~~~
HOOK: [xreq-000001:afTest/launch_all_tests] END

```