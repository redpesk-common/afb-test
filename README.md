# Installation

## Pre-requisites

[Setup the pre-requisite](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/host-configuration/docs/1_Prerequisites.html) then [install the Application Framework](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/host-configuration/docs/2_AGL_Application_Framework.html) on your host.

You will also need to install lua-devel >= 5.3 to be able to build the project.

Fedora:

```bash
dnf install lua-devel
```

OpenSuse:

```bash
zypper install lua53-devel
```

Ubuntu (>= Xenial), Debian stable:

```bash
apt-get install liblua5.3-dev
```

## Grab source and build

Download the **afb-test** binding source code using git:

```bash
git clone --recurse-submodules https://github.com/iotbzh/afb-test
cd afb-test
mkdir build
cd build
cmake .. && make
```

## Launch the example

To launch the binding use the command-line provided at the end of the build, and the afb-daemon-demo just like in the exemple below.
This will launch the test of an Helloworld binding example. The code of the test
is available from the LUA files `conf.d/controller/lua.d/helloworld.lua` and `conf.d/controller/lua.d/aftTest.lua`.

The example will run some basics tests on API verb calls and events received.

<details> <summary><b>helloworld.lua code</b></summary>

```lua
    function _callback(responseJ)
    _AFT.assertStrContains(responseJ.response, "Some String")
    end

    function _callbackError(responseJ)
    _AFT.assertStrContains(responseJ.request.info, "Ping Binder Daemon fails")
    end

    function _callbackEvent(eventName, eventData)
    _AFT.assertEquals(eventData, {data = { key = 'weird others data', another_key = 123.456 }})
    end

    _AFT.addEventToMonitor("hello/anEvent")
    _AFT.addEventToMonitor("hello/anotherEvent", _callbackEvent)

    _AFT.testVerbStatusSuccess('testPingSuccess','hello', 'ping', {})
    _AFT.testVerbResponseEquals('testPingSuccess','hello', 'ping', {}, "Some String")
    _AFT.testVerbResponseEquals('testPingSuccess','hello', 'ping', {}, "Unexpected String")
    _AFT.testVerbCb('testPingSuccess','hello', 'ping', {}, _callback)
    _AFT.testVerbStatusError('testPingError', 'hello', 'pingfail', {})
    _AFT.testVerbResponseEqualsError('testPingError', 'hello', 'pingfail', {}, "Ping Binder Daemon fails")
    _AFT.testVerbResponseEqualsError('testPingError', 'hello', 'pingfail', {}, "Ping Binder Daemon succeed")
    _AFT.testVerbCbError('testPingError', 'hello', 'pingfail', {}, _callbackError)

    _AFT.testVerbStatusSuccess('testEventAdd', 'hello', 'eventadd', {tag = 'event', name = 'anEvent'})
    _AFT.testVerbStatusSuccess('testEventSub', 'hello', 'eventsub', {tag = 'event'})
    _AFT.testVerbStatusSuccess('testEventPush', 'hello', 'eventpush', {tag = 'event', data = { key = 'some data', another_key = 123}})

    _AFT.testVerbStatusSuccess('testEventAdd', 'hello', 'eventadd', {tag = 'evt', name = 'anotherEvent'})
    _AFT.testVerbStatusSuccess('testEventSub', 'hello', 'eventsub', {tag = 'evt'})
    _AFT.testVerbStatusSuccess('testEventPush', 'hello', 'eventpush', {tag = 'evt', data = { key = 'weird others data', another_key = 123.456}})

    _AFT.testVerbStatusSuccess('testGenerateWarning', 'hello', 'verbose', {level = 4, message = 'My Warning message!'})

    _AFT.testEvtReceived("testEvent", "hello/anEvent",3000000)
    _AFT.testEvtReceived("testEventCb", "hello/anotherEvent",3000000)

    _AFT.testCustom("mytest", function()
      _AFT.assertEquals(false, false)
    end)
```
</details>

<details><summary><b>aftTest.lua code</b></summary>

```lua

_AFT.setBeforeEach(function() print("~~~~~ Begin Test ~~~~~") end)
_AFT.setAfterEach(function() print("~~~~~ End Test ~~~~~") end)

_AFT.setBeforeAll(function() print("~~~~~~~~~~ BEGIN ALL TESTS ~~~~~~~~~~") return 0 end)
_AFT.setAfterAll(function() print("~~~~~~~~~~ END ALL TESTS ~~~~~~~~~~") return 0 end)


local corout = coroutine.create( print )

_AFT.describe("testAssertEquals", function() _AFT.assertEquals(false, false) end,
                                  function() print("~~~~~ Begin Test Assert Equals ~~~~~") end,
                                  function() print("~~~~~ End Test Assert Equals ~~~~~") end)

_AFT.describe("testAssertNotEquals", function()  _AFT.assertNotEquals(true,false) end)
_AFT.describe("testAssertItemsEquals", function()	_AFT.assertItemsEquals({1,2,3},{3,1,2}) end)
_AFT.describe("testAssertAlmostEquals", function()	_AFT.assertAlmostEquals(1.25 ,1.5,0.5) end)
_AFT.describe("testAssertNotAlmostEquals", function()	_AFT.assertNotAlmostEquals(1.25,1.5,0.125) end)
_AFT.describe("testAssertEvalToTrue", function()	_AFT.assertEvalToTrue(true) end)
_AFT.describe("testAssertEvalToFalse", function()  _AFT.assertEvalToFalse(false) end)

_AFT.describe("testAssertStrContains", function()  _AFT.assertStrContains("Hello I'm a string","string") end)
_AFT.describe("testAssertStrContains", function()  _AFT.assertStrContains("Hello I'm a second string","second",5) end)

_AFT.describe("testAssertStrIContains", function()  _AFT.assertStrIContains("Hello I'm another string","I'm") end)

_AFT.describe("testAssertNotStrContains", function()  _AFT.assertNotStrContains("Hello it's me again, the other string","banana") end)
_AFT.describe("testAssertNotStrContains", function()  _AFT.assertNotStrContains("Hello it's me again, the other string","banana",8) end)

_AFT.describe("testAssertNotStrIContains", function()  _AFT.assertNotStrIContains("Hello it's not me this time !","trebuchet") end)

_AFT.describe("testAssertStrMatches", function()  _AFT.assertStrMatches("Automotive Grade Linux","Automotive Grade Linux") end)
_AFT.describe("testAssertStrMatches", function()  _AFT.assertStrMatches("Automotive Grade Linux from IoT.bzh","Automotive Grade Linux",1,22) end)
_AFT.describe("testAssertError", function()  _AFT.assertError(_AFT.assertEquals(true,true)) end)

_AFT.describe("testAssertErrorMsgEquals", function()  _AFT.assertErrorMsgEquals("attempt to call a nil value",
													  _AFT.assertStrMatches("test assertErrorMsgEquals","test",1,4)) end)
_AFT.describe("testAssertErrorMsgContains", function()	_AFT.assertErrorMsgContains("attempt to call",
														_AFT.assertStrMatches("test assertErrorMsgEquals","test",1,4)) end)
_AFT.describe("testAssertErrorMsgMatches", function()	_AFT.assertErrorMsgMatches('attempt to call a nil value',
														_AFT.assertStrMatches("test assertErrorMsgEquals","test",1,4)) end)

_AFT.describe("testAssertIs", function()	_AFT.assertIs('toto','to'..'to') end)
_AFT.describe("testAssertNotIs", function()  _AFT.assertNotIs({1,2},{1,2}) end)

_AFT.describe("testAssertIsNumber", function()  _AFT.assertIsNumber(23) end)
_AFT.describe("testAssertIsString", function()	_AFT.assertIsString("Lapin bihan") end)
_AFT.describe("testAssertIsTable", function()	_AFT.assertIsTable({1,2,3,4}) end)
_AFT.describe("testAssertIsBoolean", function()	_AFT.assertIsBoolean(true) end)
_AFT.describe("testAssertIsNil", function()	_AFT.assertIsNil(nil) end)
_AFT.describe("testAssertIsTrue", function()	_AFT.assertIsTrue(true) end)
_AFT.describe("testAssertIsFalse", function()	_AFT.assertIsFalse(false) end)
_AFT.describe("testAssertIsNaN", function()	_AFT.assertIsNaN(0/0) end)
_AFT.describe("testAssertIsInf", function()	_AFT.assertIsInf(1/0) end)
_AFT.describe("testAssertIsPlusInf", function()	_AFT.assertIsPlusInf(1/0) end)
_AFT.describe("testAssertIsMinusInf", function()	_AFT.assertIsMinusInf(-1/0) end)
_AFT.describe("testAssertIsPlusZero", function()	_AFT.assertIsPlusZero(1/(1/0)) end)
_AFT.describe("testAssertIsMinusZero", function()	_AFT.assertIsMinusZero(-1/(1/0)) end)
_AFT.describe("testAssertIsFunction", function()	_AFT.assertIsFunction(print) end)
_AFT.describe("testAssertIsThread", function()	_AFT.assertIsThread(corout) end)
_AFT.describe("testAssertIsUserdata", function()  _AFT.assertIsUserdata(_AFT.context) end)

_AFT.describe("testAssertNotIsNumber", function()  _AFT.assertNotIsNumber('a') end)
_AFT.describe("testAssertNotIsString", function()	_AFT.assertNotIsString(2) end)
_AFT.describe("testAssertNotIsTable", function()	_AFT.assertNotIsTable(2) end)
_AFT.describe("testAssertNotIsBoolean", function()	_AFT.assertNotIsBoolean(2) end)
_AFT.describe("testAssertNotIsNil", function()	_AFT.assertNotIsNil(2) end)
_AFT.describe("testAssertNotIsTrue", function()	_AFT.assertNotIsTrue(false) end)
_AFT.describe("testAssertNotIsFalse", function()	_AFT.assertNotIsFalse(true) end)
_AFT.describe("testAssertNotIsNaN", function()	_AFT.assertNotIsNaN(1) end)
_AFT.describe("testAssertNotIsInf", function()	_AFT.assertNotIsInf(2) end)
_AFT.describe("testAssertNotIsPlusInf", function()	_AFT.assertNotIsPlusInf(2) end)
_AFT.describe("testAssertNotIsMinusInf", function()	_AFT.assertNotIsMinusInf(2) end)
_AFT.describe("testAssertNotIsPlusZero", function()	_AFT.assertNotIsPlusZero(2) end)
_AFT.describe("testAssertNotIsMinusZero", function()	_AFT.assertNotIsMinusZero(2) end)
_AFT.describe("testAssertNotIsFunction", function()	_AFT.assertNotIsFunction(2) end)
_AFT.describe("testAssertNotIsThread", function()	_AFT.assertNotIsThread(2) end)
_AFT.describe("testAssertNotIsUserdata", function()	_AFT.assertNotIsUserdata(2) end)


function _callback(responseJ) _AFT.assertStrContains(responseJ.response, "Some String") end
function _callbackError(responseJ) _AFT.assertStrContains(responseJ.request.info, "Ping Binder Daemon fails") end

_AFT.describe("testAssertVerbStatusSuccess",function() _AFT.assertVerbStatusSuccess('hello', 'ping', {}) end)
_AFT.describe("testAssertVerbResponseEquals",function() _AFT.assertVerbResponseEquals('hello', 'ping', {},"Some String") end)
_AFT.describe("testAssertVerbCb",function() _AFT.assertVerbCb('hello', 'ping', {},_callback) end)
_AFT.describe("testAssertVerbStatusError",function() _AFT.assertVerbStatusError('hello', 'pingfail', {}) end)
_AFT.describe("testAssertVerbResponseEqualsError",function() _AFT.assertVerbResponseEqualsError('hello', 'pingfail', {},"Ping Binder Daemon fails") end)
_AFT.describe("testAssertVerbCbError",function() _AFT.assertVerbCbError('hello', 'pingfail', {},_callbackError) end)
```
</details>

> **NOTE**: I suggest you to take this lua file example to make your own test
> then read the following the chapter if needed to write more complicated tests.

```bash
afb-daemon --name afbd-test --port=1234 --workdir=package --ldpaths=/opt/AGL/lib64/afb:lib --token= -vvv --tracereq=common
```

<details><summary><b>On afb-daemon startup you should have:</b></summary>

```bash
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
INFO: binding [/opt/AGL/lib64/afb/ave.so] calling dynamic initialisation afbBindingVdyn
INFO: Starting creation of dynamic API ave
NOTICE: [API ave] dynamic binding AVE(ave) comes to live
INFO: API ave added
INFO: binding ave added to set main
INFO: Starting creation of dynamic API hi
NOTICE: [API hi] dynamic binding AVE(hi) comes to live
INFO: API hi added
INFO: binding hi added to set main
INFO: Starting creation of dynamic API salut
NOTICE: [API salut] dynamic binding AVE(salut) comes to live
INFO: API salut added
INFO: binding salut added to set main
INFO: Scanning dir=[/opt/AGL/lib64/afb/monitoring] for bindings
INFO: binding [/opt/AGL/lib64/afb/afb-dbus-binding.so] is a valid AFB binding V1
INFO: binding [/opt/AGL/lib64/afb/afb-dbus-binding.so] calling registering function afbBindingV1Register
INFO: API dbus added
INFO: binding /opt/AGL/lib64/afb/afb-dbus-binding.so loaded with API prefix dbus
INFO: binding [/opt/AGL/lib64/afb/authLogin.so] is a valid AFB binding V1
INFO: binding [/opt/AGL/lib64/afb/authLogin.so] calling registering function afbBindingV1Register
INFO: API auth added
INFO: binding /opt/AGL/lib64/afb/authLogin.so loaded with API prefix auth
INFO: Scanning dir=[lib] for bindings
INFO: binding [lib/aft.so] looks like an AFB binding Vdyn
INFO: binding [lib/aft.so] calling dynamic initialisation afbBindingVdyn
NOTICE: [API lib/aft.so] Controller in afbBindingVdyn
DEBUG: [API lib/aft.so] CONFIG-SCANNING dir=/opt/AGL/lib64/afb/test/etc not readable
WARNING: [API lib/aft.so] CTL-INIT JSON file found but not used : /home/Nyt/Documents/afb-test/build/package/etc/aft-test.json [/home/Nyt/Documents/afb-test/app-controller-submodule/ctl-lib/ctl-config.c:89,ConfigSearch]
INFO: [API lib/aft.so] CTL-LOAD-CONFIG: loading config filepath=./etc/aft-test.json
NOTICE: [API lib/aft.so] Controller API='afTest' info='Binding made to tests other bindings'
INFO: Starting creation of dynamic API afTest
DEBUG: [API lib/aft.so] CONFIG-SCANNING dir=/opt/AGL/lib64/afb/test/lib/plugins not readable
DEBUG: [API lib/aft.so] CONFIG-SCANNING dir=/home/Nyt/Documents/afb-test/build/package/lib/plugins not readable
WARNING: [API afTest] Plugin multiple instances in searchpath will use ./var/aft.lua [/home/Nyt/Documents/afb-test/app-controller-submodule/ctl-lib/ctl-plugin.c:238,LoadFoundPlugins]
INFO: API afTest added
INFO: binding afTest added to set main
DEBUG: Init config done
INFO: API afTest starting...
INFO: API hello starting...
NOTICE: [API hello] hello binding starting
NOTICE: API hello started
NOTICE: API afTest started
INFO: API auth starting...
NOTICE: API auth started
INFO: API ave starting...
NOTICE: [API ave] dynamic binding AVE(ave) starting
NOTICE: API ave started
INFO: API context starting...
NOTICE: API context started
INFO: API dbus starting...
NOTICE: API dbus started
INFO: API hi starting...
NOTICE: [API hi] dynamic binding AVE(hi) starting
NOTICE: API hi started
INFO: API monitor starting...
NOTICE: API monitor started
INFO: API post starting...
NOTICE: API post started
INFO: API salut starting...
NOTICE: [API salut] dynamic binding AVE(salut) starting
NOTICE: API salut started
INFO: API tictactoe starting...
NOTICE: API tictactoe started
NOTICE: Waiting port=1234 rootdir=.
NOTICE: Browser URL= http://localhost:1234
```
</details>

Then in a new terminal

``` bash
afb-client-demo ws://localhost:1234/api?token=1
afTest launch_all_tests
```

You should get something like:

``` bash
{"response":{"info":"Launching tests"},"jtype":"afb-reply","request":{"status":"success","uuid":"3fa17ce6-0029-4ef9-8e0d-38dba2a9cf38"}}
{"event":"afTest\/results","data":{"info":"Success : 71 Failures : 5"},"jtype":"afb-event"}
```
And on your afb-daemon terminal

<details><summary><b>Show</b></summary>

```bash
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
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
~~~~~ Begin Test ~~~~~
~~~~~ End Test ~~~~~
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
# Starting class: testPingSuccessCallback
# Starting test: testPingSuccessCallback.testFunction
HOOK: [xreq-000007:hello/ping] BEGIN
HOOK: [xreq-000007:hello/ping] json() -> null
HOOK: [xreq-000007:hello/ping] reply[success]("Some String", Ping Binder Daemon tag=pingSample count=4 query=null)
HOOK: [xreq-000007:hello/ping] END
# Starting class: testPingError
# Starting test: testPingError.testFunction
HOOK: [xreq-000008:hello/pingfail] BEGIN
HOOK: [xreq-000008:hello/pingfail] reply[failed](null, Ping Binder Daemon fails)
HOOK: [xreq-000008:hello/pingfail] END
# Starting class: testPingErrorAndResponse
# Starting test: testPingErrorAndResponse.testFunction
HOOK: [xreq-000009:hello/pingfail] BEGIN
HOOK: [xreq-000009:hello/pingfail] reply[failed](null, Ping Binder Daemon fails)
HOOK: [xreq-000009:hello/pingfail] END
#   Failure:  ./var/aft.lua:242: Received the not expected value: "Ping Binder Daemon fails"
# Starting class: testPingErrorResponseFail
# Starting test: testPingErrorResponseFail.testFunction
HOOK: [xreq-000010:hello/pingfail] BEGIN
HOOK: [xreq-000010:hello/pingfail] reply[failed](null, Ping Binder Daemon fails)
HOOK: [xreq-000010:hello/pingfail] END
# Starting class: testPingErrorCallback
# Starting test: testPingErrorCallback.testFunction
HOOK: [xreq-000011:hello/pingfail] BEGIN
HOOK: [xreq-000011:hello/pingfail] reply[failed](null, Ping Binder Daemon fails)
HOOK: [xreq-000011:hello/pingfail] END
# Starting class: testEventAddanEvent
# Starting test: testEventAddanEvent.testFunction
HOOK: [xreq-000012:hello/eventadd] BEGIN
HOOK: [xreq-000012:hello/eventadd] get(tag) -> { name: tag, value: event, path: (null) }
HOOK: [xreq-000012:hello/eventadd] get(name) -> { name: name, value: anEvent, path: (null) }
HOOK: [xreq-000012:hello/eventadd] reply[success](null, (null))
HOOK: [xreq-000012:hello/eventadd] END
# Starting class: testEventSubanEvent
# Starting test: testEventSubanEvent.testFunction
HOOK: [xreq-000013:hello/eventsub] BEGIN
HOOK: [xreq-000013:hello/eventsub] get(tag) -> { name: tag, value: event, path: (null) }
HOOK: [xreq-000013:hello/eventsub] subscribe(hello/anEvent:1) -> 0
HOOK: [xreq-000013:hello/eventsub] reply[success](null, (null))
HOOK: [xreq-000013:hello/eventsub] END
# Starting class: testEventPushanEvent
# Starting test: testEventPushanEvent.testFunction
HOOK: [xreq-000014:hello/eventpush] BEGIN
HOOK: [xreq-000014:hello/eventpush] get(tag) -> { name: tag, value: event, path: (null) }
HOOK: [xreq-000014:hello/eventpush] get(data) -> { name: data, value: { "another_key": 123, "key": "some data" }, path: (null) }
DEBUG: [API afTest] Received event=hello/anEvent, query={ "another_key": 123, "key": "some data" }
WARNING: [API afTest] CtlDispatchEvent: fail to find uid=hello/anEvent in action event section [/home/Nyt/Documents/tests/app-afb-test/app-controller-submodule/ctl-lib/ctl-event.c:46,CtrlDispatchApiEvent]
HOOK: [xreq-000014:hello/eventpush] reply[success](null, (null))
HOOK: [xreq-000014:hello/eventpush] END
# Starting class: testEventAddanotherEvent
# Starting test: testEventAddanotherEvent.testFunction
HOOK: [xreq-000015:hello/eventadd] BEGIN
HOOK: [xreq-000015:hello/eventadd] get(tag) -> { name: tag, value: evt, path: (null) }
HOOK: [xreq-000015:hello/eventadd] get(name) -> { name: name, value: anotherEvent, path: (null) }
HOOK: [xreq-000015:hello/eventadd] reply[success](null, (null))
HOOK: [xreq-000015:hello/eventadd] END
# Starting class: testEventSubanotherEvent
# Starting test: testEventSubanotherEvent.testFunction
HOOK: [xreq-000016:hello/eventsub] BEGIN
HOOK: [xreq-000016:hello/eventsub] get(tag) -> { name: tag, value: evt, path: (null) }
HOOK: [xreq-000016:hello/eventsub] subscribe(hello/anotherEvent:2) -> 0
HOOK: [xreq-000016:hello/eventsub] reply[success](null, (null))
HOOK: [xreq-000016:hello/eventsub] END
# Starting class: testEventPushanotherEvent
# Starting test: testEventPushanotherEvent.testFunction
HOOK: [xreq-000017:hello/eventpush] BEGIN
HOOK: [xreq-000017:hello/eventpush] get(tag) -> { name: tag, value: evt, path: (null) }
HOOK: [xreq-000017:hello/eventpush] get(data) -> { name: data, value: { "another_key": 123.456, "key": "weird others data" }, path: (null) }
DEBUG: [API afTest] Received event=hello/anotherEvent, query={ "another_key": 123.456, "key": "weird others data" }
WARNING: [API afTest] CtlDispatchEvent: fail to find uid=hello/anotherEvent in action event section [/home/Nyt/Documents/tests/app-afb-test/app-controller-submodule/ctl-lib/ctl-event.c:46,CtrlDispatchApiEvent]
HOOK: [xreq-000017:hello/eventpush] reply[success](null, (null))
HOOK: [xreq-000017:hello/eventpush] END
# Starting class: testGenerateWarning
# Starting test: testGenerateWarning.testFunction
HOOK: [xreq-000018:hello/verbose] BEGIN
HOOK: [xreq-000018:hello/verbose] json() -> { "message": "My Warning message!", "level": 4 }
WARNING: [REQ/API hello] verbose called for My Warning message! [/home/abuild/rpmbuild/BUILD/app-framework-binder-5.99/bindings/samples/HelloWorld.c:330,verbose]
HOOK: [xreq-000018:hello/verbose] vverbose(4:warning, /home/abuild/rpmbuild/BUILD/app-framework-binder-5.99/bindings/samples/HelloWorld.c, 330, verbose) -> verbose called for My Warning message!
HOOK: [xreq-000018:hello/verbose] reply[success](null, (null))
HOOK: [xreq-000018:hello/verbose] END
# Starting test: testanEventReceived
~~~~~ Begin Test ~~~~~
#   Failure:  ./var/aft.lua:176: No event 'hello/anEvent' received
#   expected: true, actual: false
# Starting test: testanotherEventReceived
~~~~~ Begin Test ~~~~~
#   Failure:  ./var/aft.lua:176: No event 'hello/anotherEvent' received
#   expected: true, actual: false
# Starting class: testAssertEquals
# Starting test: testAssertEquals.testFunction
~~~~~ Begin Test Assert Equals ~~~~~
~~~~~ End Test Assert Equals ~~~~~
# Starting class: testAssertNotEquals
# Starting test: testAssertNotEquals.testFunction
# Starting class: testAssertItemsEquals
# Starting test: testAssertItemsEquals.testFunction
# Starting class: testAssertAlmostEquals
# Starting test: testAssertAlmostEquals.testFunction
# Starting class: testAssertNotAlmostEquals
# Starting test: testAssertNotAlmostEquals.testFunction
# Starting class: testAssertEvalToTrue
# Starting test: testAssertEvalToTrue.testFunction
# Starting class: testAssertEvalToFalse
# Starting test: testAssertEvalToFalse.testFunction
# Starting class: testAssertStrContains
# Starting test: testAssertStrContains.testFunction
# Starting test: testAssertStrContains.testFunction
# Starting class: testAssertStrIContains
# Starting test: testAssertStrIContains.testFunction
# Starting class: testAssertNotStrContains
# Starting test: testAssertNotStrContains.testFunction
# Starting test: testAssertNotStrContains.testFunction
# Starting class: testAssertNotStrIContains
# Starting test: testAssertNotStrIContains.testFunction
# Starting class: testAssertStrMatches
# Starting test: testAssertStrMatches.testFunction
# Starting test: testAssertStrMatches.testFunction
# Starting class: testAssertError
# Starting test: testAssertError.testFunction
# Starting class: testAssertErrorMsgEquals
# Starting test: testAssertErrorMsgEquals.testFunction
# Starting class: testAssertErrorMsgContains
# Starting test: testAssertErrorMsgContains.testFunction
# Starting class: testAssertErrorMsgMatches
# Starting test: testAssertErrorMsgMatches.testFunction
# Starting class: testAssertIs
# Starting test: testAssertIs.testFunction
# Starting class: testAssertNotIs
# Starting test: testAssertNotIs.testFunction
# Starting class: testAssertIsNumber
# Starting test: testAssertIsNumber.testFunction
# Starting class: testAssertIsString
# Starting test: testAssertIsString.testFunction
# Starting class: testAssertIsTable
# Starting test: testAssertIsTable.testFunction
# Starting class: testAssertIsBoolean
# Starting test: testAssertIsBoolean.testFunction
# Starting class: testAssertIsNil
# Starting test: testAssertIsNil.testFunction
# Starting class: testAssertIsTrue
# Starting test: testAssertIsTrue.testFunction
# Starting class: testAssertIsFalse
# Starting test: testAssertIsFalse.testFunction
# Starting class: testAssertIsNaN
# Starting test: testAssertIsNaN.testFunction
# Starting class: testAssertIsInf
# Starting test: testAssertIsInf.testFunction
# Starting class: testAssertIsPlusInf
# Starting test: testAssertIsPlusInf.testFunction
# Starting class: testAssertIsMinusInf
# Starting test: testAssertIsMinusInf.testFunction
# Starting class: testAssertIsPlusZero
# Starting test: testAssertIsPlusZero.testFunction
# Starting class: testAssertIsMinusZero
# Starting test: testAssertIsMinusZero.testFunction
# Starting class: testAssertIsFunction
# Starting test: testAssertIsFunction.testFunction
# Starting class: testAssertIsThread
# Starting test: testAssertIsThread.testFunction
# Starting class: testAssertIsUserdata
# Starting test: testAssertIsUserdata.testFunction
# Starting class: testAssertNotIsNumber
# Starting test: testAssertNotIsNumber.testFunction
# Starting class: testAssertNotIsString
# Starting test: testAssertNotIsString.testFunction
# Starting class: testAssertNotIsTable
# Starting test: testAssertNotIsTable.testFunction
# Starting class: testAssertNotIsBoolean
# Starting test: testAssertNotIsBoolean.testFunction
# Starting class: testAssertNotIsNil
# Starting test: testAssertNotIsNil.testFunction
# Starting class: testAssertNotIsTrue
# Starting test: testAssertNotIsTrue.testFunction
# Starting class: testAssertNotIsFalse
# Starting test: testAssertNotIsFalse.testFunction
# Starting class: testAssertNotIsNaN
# Starting test: testAssertNotIsNaN.testFunction
# Starting class: testAssertNotIsInf
# Starting test: testAssertNotIsInf.testFunction
# Starting class: testAssertNotIsPlusInf
# Starting test: testAssertNotIsPlusInf.testFunction
# Starting class: testAssertNotIsMinusInf
# Starting test: testAssertNotIsMinusInf.testFunction
# Starting class: testAssertNotIsPlusZero
# Starting test: testAssertNotIsPlusZero.testFunction
# Starting class: testAssertNotIsMinusZero
# Starting test: testAssertNotIsMinusZero.testFunction
# Starting class: testAssertNotIsFunction
# Starting test: testAssertNotIsFunction.testFunction
# Starting class: testAssertNotIsThread
# Starting test: testAssertNotIsThread.testFunction
# Starting class: testAssertNotIsUserdata
# Starting test: testAssertNotIsUserdata.testFunction
# Starting class: testAssertVerbStatusSuccess
# Starting test: testAssertVerbStatusSuccess.testFunction
HOOK: [xreq-000019:hello/ping] BEGIN
HOOK: [xreq-000019:hello/ping] json() -> null
HOOK: [xreq-000019:hello/ping] reply[success]("Some String", Ping Binder Daemon tag=pingSample count=5 query=null)
HOOK: [xreq-000019:hello/ping] END
# Starting class: testAssertVerbResponseEquals
# Starting test: testAssertVerbResponseEquals.testFunction
HOOK: [xreq-000020:hello/ping] BEGIN
HOOK: [xreq-000020:hello/ping] json() -> null
HOOK: [xreq-000020:hello/ping] reply[success]("Some String", Ping Binder Daemon tag=pingSample count=6 query=null)
HOOK: [xreq-000020:hello/ping] END
# Starting class: testAssertVerbCb
# Starting test: testAssertVerbCb.testFunction
HOOK: [xreq-000021:hello/ping] BEGIN
HOOK: [xreq-000021:hello/ping] json() -> null
HOOK: [xreq-000021:hello/ping] reply[success]("Some String", Ping Binder Daemon tag=pingSample count=7 query=null)
HOOK: [xreq-000021:hello/ping] END
# Starting class: testAssertVerbStatusError
# Starting test: testAssertVerbStatusError.testFunction
HOOK: [xreq-000022:hello/pingfail] BEGIN
HOOK: [xreq-000022:hello/pingfail] reply[failed](null, Ping Binder Daemon fails)
HOOK: [xreq-000022:hello/pingfail] END
# Starting class: testAssertVerbResponseEqualsError
# Starting test: testAssertVerbResponseEqualsError.testFunction
HOOK: [xreq-000023:hello/pingfail] BEGIN
HOOK: [xreq-000023:hello/pingfail] reply[failed](null, Ping Binder Daemon fails)
HOOK: [xreq-000023:hello/pingfail] END
#   Failure:  ./var/aft.lua:242: Received the not expected value: "Ping Binder Daemon fails"
# Starting class: testAssertVerbCbError
# Starting test: testAssertVerbCbError.testFunction
HOOK: [xreq-000024:hello/pingfail] BEGIN
HOOK: [xreq-000024:hello/pingfail] reply[failed](null, Ping Binder Daemon fails)
HOOK: [xreq-000024:hello/pingfail] END
# Ran 76 tests in 0.010 seconds, 71 successes, 5 failures
HOOK: [xreq-000001:afTest/launch_all_tests] subscribe(afTest/results:3) -> 0
~~~~~~~~~~ END ALL TESTS ~~~~~~~~~~
HOOK: [xreq-000001:afTest/launch_all_tests] END

```

</details>

## Write your own tests

### Binding configuration

In the package directory you have a file name `test-config.json` that contains
the controller binding configuration. Here, you have to change or define the
*files* key in the *args* object of the *onload* section.

Also you MUST specify which *api* you need to trace to perform your tests.
Specify which api to trace using a pattern.

Edit the JSON array to point to your tests files.

Here is an example:

```json
{
    "id": "http://iot.bzh/download/public/schema/json/ctl-schema.json#",
    "$schema": "http://iot.bzh/download/public/schema/json/ctl-schema.json#",
    "metadata": {
        "uid": "Test",
        "version": "1.0",
        "api": "test",
        "info": "Binding made to tests other bindings",
        "require": [
            "hello"
        ]
    },
    "onload": {
        "uid": "launch_all_tests",
        "info": "Launch all the tests",
        "action": "lua://AFT#_launch_test",
        "args": {
            "trace": "hello",
            "files": ["helloworld.lua"]
        }
    }
}
```

### LUA Test files

First, ensure that you put your LUA tests files in the `var` directory from the
binding root directory.

You have two differents things to take in account when you'll write your tests
using this framework: *test* and *assertions*.

*Assertions* are functions mean to test an atomic operation result.
(ie: `1+1 = 2` is an assertion)

*Test* functions represent a test (Unbelievable), they represent a set of one or
several *assertions* which are all needed to succeed to valid the test.

The framework came with several *test* and *assertion* functions to simply be
able to test verb calls and events receiving. Use the simple one as often as
possible and if you need more use the one that call a callback. Specifying a
callback let you add assertions and enrich the test.

### Reference

#### Binding Test functions

* **_AFT.testVerbStatusSuccess(testName, api, verb, args, setUp, tearDown)**

    Simply test that the call of a verb successfully returns.

    *setUp* and *tearDown* are functions that can be added to your context, it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()** (if set) functions, *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbStatusError(testName, api, verb, args, setUp, tearDown)**

    The inverse than above.

    *setUp* and *tearDown* are functions that can be added to your context, it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()** (if set) functions, *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbResponseEquals(testName, api, verb, args, expectedResponse, setUp, tearDown)**

    Test that the call of a verb successfully returns and that verb's response
    is equals to the *expectedResponse*.

    *setUp* and *tearDown* are functions that can be added to your context, it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()** (if set) functions, *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbResponseEqualsError(testName, api, verb, args, expectedResponse, setUp, tearDown)**

    The inverse than above.

    *setUp* and *tearDown* are functions that can be added to your context, it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()** (if set) functions, *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbCb(testName, api, verb, args, expectedResponse, callback, setUp, tearDown)**

    Test the call of a verb with a custom callback. From this callback you
    will need to make some assertions on what you need (verb JSON return object
    content mainly).

    If you don't need to test the response simply specify an empty LUA table.

    *setUp* and *tearDown* are functions that can be added to your context, it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()** (if set) functions, *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbCbError(testName, api, verb, args, expectedResponse, callback, setUp, tearDown)**

    Should return success on failure.

    *setUp* and *tearDown* are functions that can be added to your context, it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()** (if set) functions, *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if set) functions.

* **_AFT.testEvtReceived(testName, eventName, timeout)**

    Prior to be able to check that an event has been received, you have to
    register the event with the test framework using **_AFT.addEventToMonitor**
    function.

    Check if an event has been correctly received in time (timeout in µs). An event name use the
    application framework naming scheme: **api/event_name**.

* **_AFT.testEvtNotReceived(testName, eventName, timeout)**

    Prior to be able to check that an event has been received, you have to
    register the event with the test framework using **_AFT.addEventToMonitor**
    function.

    Check if an event has been correctly received in time (timeout in µs). An event name use the
    application framework naming scheme: **api/event_name**.

#### Binding Assert functions

* **_AFT.assertVerbStatusSuccess(api, verb, args)**

    Simply test that the call of a verb successfully returns.

* **_AFT.assertVerbStatusError(api, verb, args)**

    The inverse than above.

* **_AFT.assertVerbResponseEquals(api, verb, args, expectedResponse)**

    Test that the call of a verb successfully returns and that verb's response
    is equals to the *expectedResponse*.

* **_AFT.assertVerbResponseEqualsError(api, verb, args, expectedResponse)**

    The inverse than above.

* **_AFT.assertVerbCb(api, verb, args, expectedResponse, callback)**

    Test the call of a verb with a custom callback. From this callback you
    will need to make some assertions on what you need (verb JSON return object
    content mainly).

    If you don't need to test the response simply specify an empty LUA table.

* **_AFT.assertVerbCbError(api, verb, args, expectedResponse, callback)**

    Should return success on failure.

* **_AFT.assertEvtReceived(eventName, timeout)**

    Prior to be able to check that an event has been received, you have to
    register the event with the test framework using **_AFT.addEventToMonitor**
    function.

    Check if an event has been correctly received in time (timeout in µs). An event name use the
    application framework naming scheme: **api/event_name**.

* **_AFT.assertEvtNotReceived(eventName, timeout)**

    Prior to be able to check that an event has been received, you have to
    register the event with the test framework using **_AFT.addEventToMonitor**
    function.

    Check if an event has been correctly received in time (timeout in µs). An event name use the
    application framework naming scheme: **api/event_name**.

#### Test Framework functions

* **_AFT.addEventToMonitor(eventName, callback)**

    Add a binding event in the test framework to be able to assert its reception
    . You'll need to add as much as events you expect to receive. You could also
    specify a callback to test deeper that the event is as you want to. The
    callback will happens after the assertion that it has been received so you
    can work on data that the event eventually carry.

* **_AFT.setJunitFile(filePath)**

    Set the *JUnit* file path. When *JUnit* is set as the output type for the
    test framework.

* **_AFT.setBeforeEach(function)**

    Set the **_AFT.beforeEach()** function which is used to run the *function* before each tests.

* **_AFT.setAfterEach(function)**

    Set the **_AFT.afterEach()** function which is used to run the *function* after each tests.

* **_AFT.setBeforeAll(function)**

    Set the **_AFT.beforeAll()** function which is used to run the *function* before all tests. If the given function is successful it has to return 0 else it will return an error.

* **_AFT.setAfterAll(function)**

    Set the **_AFT.afterAll()** function which is used to run the *function* after all tests. If the given function is successful it has to return 0 else it will return an error.

* **_AFT.describe(testName, testFunction, setUp, tearDown)**

    Give a context to a custom test. *testFunction* will be given the name provided by *testName* and will be tested.

    *setUp* and *tearDown* are functions that can be added to your context, it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()** (if set) functions, *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if set) functions.

* **_AFT.setBefore(testName, beforeTestFunction)**
    Set a function to be ran at the beginning of the given *testName* function.

    <details><summary><b>Exemple</b></summary> 

    ```lua
    _AFT.testVerbStatusSuccess('testPingSuccess','hello', 'ping', {})
    _AFT.setBefore("testPingSuccess",function() print("~~~~~ Begin testPingSuccess ~~~~~") end)
    _AFT.setAfter("testPingSuccess",function() print("~~~~~ End testPingSuccess ~~~~~") end)
    ```
    </details>

* **_AFT.setBefore(testName, beforeTestFunction)**
    Set a function to be ran at the end of the given *testName* function.

#### LuaUnit Assertion functions

##### General Assertions

* **_AFT.assertEquals(actual, expected)**

    Assert that two values are equal.

    For tables, the comparison is a deep comparison :

  * number of elements must be the same
  * tables must contain the same keys
  * each key must contain the same values. The values are also compared recursively with deep comparison.

    LuaUnit provides other table-related assertions, see [Table assertions](http://luaunit.readthedocs.io/en/luaunit_v3_2_1/#assert-table)

* **_AFT.assertNotEquals(actual, expected)**

    Assert that two values are different. The assertion fails if the two values are identical.

    It also uses table deep comparison.

* **_AFT.assertAlmostEquals(actual, expected, margin)**

    Assert that two floating point numbers are almost equal.

    When comparing floating point numbers, strict equality does not work. Computer arithmetic is so that an operation that mathematically yields 1.00000000 might yield 0.999999999999 in lua . That’s why you need an almost equals comparison, where you specify the error margin.

* **_AFT.assertNotAlmostEquals(actual, expected, margin)**

    Assert that two floating point numbers are not almost equal.

##### Value assertions

* **_AFT.assertEvalToTrue(value)**

    Assert that a given value evals to true. Lua coercion rules are applied so that values like 0,"",1.17 succeed
    in this assertion. If provided, extra_msg is a string which will be printed along with the failure message.

* **_AFT.assertEvalToFalse(Value)**

    Assert that a given value eval to *false*. Lua coercion rules are applied so that *nil* and *false* succeed in this
    assertion. If provided, extra_msg is a string which will be printed along with the failure message.

* **_AFT.assertIsTrue(value)**

    Assert that a given value compares to true. Lua coercion rules are applied so that values like 0, "", 1.17 all compare to true.

* **_AFT.assertIsFalse(value)**

    Assert that a given value compares to false. Lua coercion rules are applied so that only nil and false all compare to false.

* **_AFT.assertIsNil(value)**

    Assert that a given value is nil .

* **_AFT.assertNotIsNil(value)**

    Assert that a given value is not *nil* . Lua coercion rules are applied
    so that values like ``0``, ``""``, ``false`` all validate the assertion.
    If provided, *extra_msg* is a string which will be printed along with the failure message.

* **_AFT.assertIs(actual, expected)**

    Assert that two variables are identical. For string, numbers, boolean and for nil, this gives the same result as assertEquals() . For the other types, identity means that the two variables refer to the same object.

    Example :

    `s1='toto'
    s2='to'..'to'
    t1={1,2}
    t2={1,2}
    luaunit.assertIs(s1,s1) -- ok
    luaunit.assertIs(s1,s2) -- ok
    luaunit.assertIs(t1,t1) -- ok
    luaunit.assertIs(t1,t2) -- fail`

* **_AFT.assertNotIs(actual, expected)**

    Assert that two variables are not identical, in the sense that they do not refer to the same value. See assertIs() for more details.

##### Scientific assertions

>**Note**
>If you need to deal with value minus zero, be very careful because Lua versions are inconsistent on how they treat the >syntax -0 : it creates either a plus zero or a minus zero . Multiplying or dividing 0 by -1 also yields inconsistent >results. The reliable way to create the -0 value is : minusZero = -1 / (1/0)

* **_AFT.assertIsNaN(value)**
    Assert that a given number is a *NaN* (Not a Number), according to the definition of IEEE-754_ .
    If provided, *extra_msg* is a string which will be printed along with the failure message.

* **_AFT.assertIsPlusInf(value)**

    Assert that a given number is *plus infinity*, according to the definition of IEEE-754_ .
    If provided, *extra_msg* is a string which will be printed along with the failure message.

* **_AFT.assertIsMinusInf(value)**

    Assert that a given number is *minus infinity*, according to the definition of IEEE-754_ .
    If provided, *extra_msg* is a string which will be printed along with the failure message.

* **_AFT.assertIsInf(value)**

    Assert that a given number is *infinity* (either positive or negative), according to the definition of IEEE-754_ .
    If provided, *extra_msg* is a string which will be printed along with the failure message.

* **_AFT.assertIsPlusZero(value)**

    Assert that a given number is *+0*, according to the definition of IEEE-754_ . The
    verification is done by dividing by the provided number and verifying that it yields
    *infinity* . If provided, *extra_msg* is a string which will be printed along with the failure message.

    Be careful when dealing with *+0* and *-0*, see note above

* **_AFT.assertIsMinusZero(value)**

    Assert that a given number is *-0*, according to the definition of IEEE-754_ . The
    verification is done by dividing by the provided number and verifying that it yields
    *minus infinity* . If provided, *extra_msg* is a string which will be printed along with the failure message.

    Be careful when dealing with *+0* and *-0*

##### String assertions

Assertions related to string and patterns.

* **_AFT.assertStrContains(str, sub[, useRe])**

    Assert that a string contains the given substring or pattern.

    By default, substring is searched in the string. If useRe is provided and is true, sub is treated as a pattern which is searched inside the string str .

* **_AFT.assertStrIContains(str, sub)**

    Assert that a string contains the given substring, irrespective of the case.

    Not that unlike assertStrcontains(), you can not search for a pattern.

* **_AFT.assertNotStrContains(str, sub, useRe)**

    Assert that a string does not contain a given substring or pattern.

    By default, substring is searched in the string. If useRe is provided and is true, sub is treated as a pattern which is searched inside the string str .

* **_AFT.assertNotStrIContains(str, sub)**

    Assert that a string does not contain the given substring, irrespective of the case.

    Not that unlike assertNotStrcontains(), you can not search for a pattern.

* **_AFT.assertStrMatches(str, pattern[, start[, final]])**

    Assert that a string matches the full pattern pattern.

    If start and final are not provided or are nil, the pattern must match the full string, from start to end. The functions allows to specify the expected start and end position of the pattern in the string.

##### Error assertions

Error related assertions, to verify error generation and error messages.

* **_AFT.assertError(func, ...)**

    Assert that calling functions func with the arguments yields an error. If the function does not yield an error, the assertion fails.

    Note that the error message itself is not checked, which means that this function does not distinguish between the legitimate error that you expect and another error that might be triggered by mistake.

    The next functions provide a better approach to error testing, by checking explicitly the error message content.

>**Note**
>When testing LuaUnit, switching from assertError() to assertErrorMsgEquals() revealed quite a few bugs!

* **_AFT.assertErrorMsgEquals(expectedMsg, func, ...)**

    Assert that calling function func will generate exactly the given error message. If the function does not yield an error, or if the error message is not identical, the assertion fails.

    Be careful when using this function that error messages usually contain the file name and line number information of where the error was generated. This is usually inconvenient. To ignore the filename and line number information, you can either use a pattern with assertErrorMsgMatches() or simply check for the message containt with assertErrorMsgContains() .

* **_AFT.assertErrorMsgContains(partialMsg, func, ...)**

    Assert that calling function func will generate an error message containing partialMsg . If the function does not yield an error, or if the expected message is not contained in the error message, the assertion fails.

* **_AFT.assertErrorMsgMatches(expectedPattern, func, ...)**

    Assert that calling function func will generate an error message matching expectedPattern . If the function does not yield an error, or if the error message does not match the provided patternm the assertion fails.

    Note that matching is done from the start to the end of the error message. Be sure to escape magic all magic characters with % (like -+.?\*) .

##### Type assertions

The following functions all perform type checking on their argument. If the received value is not of the right type, the failure message will contain the expected type, the received type and the received value to help you identify better the problem.

* **_AFT.assertIsNumber(value)**

    Assert that the argument is a number (integer or float)

* **_AFT.assertIsString(value)**

    Assert that the argument is a string.

* **_AFT.assertIsTable(value)**

    Assert that the argument is a table.

* **_AFT.assertIsBoolean(value)**

    Assert that the argument is a boolean.

* **_AFT.assertIsFunction(value)**

    Assert that the argument is a function.

* **_AFT.assertIsUserdata(value)**

    Assert that the argument is a userdata.

* **_AFT.assertIsThread(value)**

    Assert that the argument is a coroutine (an object with type thread ).

* **_AFT.assertNotIsThread(value)**

    Assert that the argument is a not coroutine (an object with type thread ).

##### Table assertions

* **_AFT.assertItemsEquals(actual, expected)**

    Assert that two tables contain the same items, irrespective of their keys.

    This function is practical for example if you want to compare two lists but where items are not in the same order:

    `luaunit.assertItemsEquals( {1,2,3}, {3,2,1} ) -- assertion succeeds`

    The comparison is not recursive on the items: if any of the items are tables, they are compared using table equality (like as in assertEquals() ), where the key matters.

    `luaunit.assertItemsEquals( {1,{2,3},4}, {4,{3,2,},1} ) -- assertion fails because {2,3} ~= {3,2}`