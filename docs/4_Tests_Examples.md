# Test example

## helloworld.lua

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

    _AFT.testVerbStatusSkipped('testEventSub', 'hello', 'eventsub', {tag = 'evt'})

    _AFT.testVerbStatusSuccess('testGenerateWarning', 'hello', 'verbose', {level = 4, message = 'My Warning message!'})

    _AFT.testEvtGrpReceived("TestEventGroupReceived",{"hello/anEvent","hello/anotherEvent"},300000)
    _AFT.testEvtGrpNotReceived("TestEventGroupNotReceived",{"hello/anEvent","hello/anotherEvent"},300000)

    _AFT.testEvtReceived("testEvent", "hello/anEvent",300000)
    _AFT.testEvtReceived("testEventCb", "hello/anotherEvent",300000)

    _AFT.describe("myTestLabel", function()
      _AFT.assertEquals(false, false)
    end)
```

## aftTest.lua

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
_AFT.describe("testAssertItemsEquals", function()  _AFT.assertItemsEquals({1,2,3},{3,1,2}) end)
_AFT.describe("testAssertAlmostEquals", function()  _AFT.assertAlmostEquals(1.25 ,1.5,0.5) end)
_AFT.describe("testAssertNotAlmostEquals", function()  _AFT.assertNotAlmostEquals(1.25,1.5,0.125) end)
_AFT.describe("testAssertEvalToTrue", function()  _AFT.assertEvalToTrue(true) end)
_AFT.describe("testAssertEvalToFalse", function()  _AFT.assertEvalToFalse(false) end)

_AFT.describe("testAssertStrContains", function()  _AFT.assertStrContains("Hello I'm a string","string") end)
_AFT.describe("testAssertStrContains", function()  _AFT.assertStrContains("Hello I'm a second string","second",5) end)

_AFT.describe("testAssertStrIContains", function()  _AFT.assertStrIContains("Hello I'm another string","I'm") end)

_AFT.describe("testAssertNotStrContains", function()  _AFT.assertNotStrContains("Hello it's me again, the other string","banana") end)
_AFT.describe("testAssertNotStrContains", function()  _AFT.assertNotStrContains("Hello it's me again, the other string","banana",8) end)
...
...
...
_AFT.describe("testAssertNotIsUserdata", function()  _AFT.assertNotIsUserdata(2) end)


function _callback(responseJ) _AFT.assertStrContains(responseJ.response, "Some String") end
function _callbackError(responseJ) _AFT.assertStrContains(responseJ.request.info, "Ping Binder Daemon fails") end

_AFT.describe("testAssertVerbStatusSuccess",function() _AFT.assertVerbStatusSuccess('hello', 'ping', {}) end)
_AFT.describe("testAssertVerbStatusSkipped",function() _AFT.assertVerbStatusSkipped('hello', 'ping', {}) end)
_AFT.describe("testAssertVerbResponseEquals",function() _AFT.assertVerbResponseEquals('hello', 'ping', {},"Some String") end)
_AFT.describe("testAssertVerbCb",function() _AFT.assertVerbCb('hello', 'ping', {},_callback) end)
_AFT.describe("testAssertVerbStatusError",function() _AFT.assertVerbStatusError('hello', 'pingfail', {}) end)
_AFT.describe("testAssertVerbResponseEqualsError",function() _AFT.assertVerbResponseEqualsError('hello', 'pingfail', {},"Ping Binder Daemon fails") end)
_AFT.describe("testAssertVerbCbError",function() _AFT.assertVerbCbError('hello', 'pingfail', {},_callbackError) end)
```

> **Suggestion**: take these lua files as example to make your own test, then read the following chapter if needed to write more complex tests.
