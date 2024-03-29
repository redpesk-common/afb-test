# Write the tests

## Create the test tree

At the root of your project, create a test-dedicated directory that holds
all your test materials. A classic test tree looks like the following:

```tree
test
├── CMakeLists.txt
├── afb-test
└── CMakeLists.txt
    ├── etc
    │   ├── CMakeLists.txt
    │   └── aft-middlename.json
    ├── fixtures
    │   ├── CMakeLists.txt
    │   ├── helper.sh
    │   ├── data
    │   └── plugin.lua
    └── tests
        ├── CMakeLists.txt
        ├── test01.lua
        ├── test02.lua
        └── test03.lua
 ...
```

Here is a description of each subdirectory purpose:

- *etc*: Holds the test binding configuration in a JSON file.
- *fixtures*: contains all external needed files to run your tests.
  This subdirectory is primarily used to inject data or a plugin
  with the mock-up APIs code in a LUA or C plugin.
- *tests*: Contains only the tests written in LUA for your binding.

## Create your configuration file

The configuration file describes your test API and how it launches the tests.
A test binding does not provide verbs.
This configuration describes the API verb(s) and mocked-up APIs.
Following are the `key` descriptions for the configuration file:

### `metadata` section

- `uid`: A simple label useful for debugging.
- `version` (optional): The test's version.
- `info` (optional): Provides information about the test.
- `api`: The name your test binding takes.
  Formerly, the name was the test API name prefixed with `aft`
  (i.e. `aft-<tested-api-name>`).
- `require`: The tested API's name. This key ensure that the tested API is
  correctly launched and initialized so the test binding can test it.

### `testVerb` section

- `uid`: The verb name.
- `info` (optional): Provides information about the verb.
- `action`: A special string indicating the function to trigger when the verb is
  called. The verb is always the same about the test binding.
- `args` Contains the following:
  - `trace`: The name of the tested API you are testing. `trace` is
   needed to allow the test binding trace the tested API and retrieve through
   the binder's monitoring feature `calls` and `events`.
  - `files`: A string or an array of strings of the LUA files with your tests.
   Only provide the file name.  Do not provide the path.

### `mapis` (mocked up API), section

- `uid`: The mocked up API's name
- `info` (optional): Provides information on the mock-up API.
- `libs`: The LUA script or C plugin file name.

#### `verbs` section

Describes the implemented mocked up API verbs. Each verb maps to a function
name that is executed when the verb is called.

- `uid`: The verb's name.
- `info` (optional): Provides information on the verb.
- `action`: A URI string that points to a C plugin or LUA script's function that
  is executes when the verb is called. The format of the action URI is:
 `<lua|plugin|api>`://`<C plugin's name|api's name|lua script name>`#`<function|verb's name>`

#### `events` section

Allows you to trigger a function when a described event is received.
The trigger can be for any event on which you need to apply modifications.
You do not have to enumerate each possible event that the mocked up API can
generate.  You could avoid this section if you do not want to execute a function
when an event is received.

- `uid`: The event's name (e.g. `<api>/<event-name>`)
- `info` (optional): Provides information about the event.
- `action`: A URI string that points to a C plugin or LUA script's function that
  is executed when an event is received. The format of the action URI is:
  `<lua|plugin|api>`://`<C plugin's name|api's name|lua script name>`#`<function|verb's name>`.
  The action `lua://AFT#_evt_catcher_` is the default `afb-test` events listener.

### Configuration examples

Here is a simple example:

```json
{
    "id": "http://iot.bzh/download/public/schema/json/ctl-schema.json#",
    "$schema": "http://iot.bzh/download/public/schema/json/ctl-schema.json#",
    "metadata": {
        "uid": "Hello_Test",
        "version": "1.0",
        "api": "aft-example",
        "info": "Binding made to test other bindings",
        "require": [
            "hello"
        ]
    },
    "testVerb": {
        "uid": "testing-hello",
        "info": "Launch the tests against hello api",
        "action": "lua://AFT#_launch_test",
        "args": {
            "trace": "hello",
            "files": ["aftTest.lua","helloworld.lua"]
        }
    }
}
```

Following is another example that uses a mocked up `low-can` API:

```json
{
    "id": "http://iot.bzh/download/public/schema/json/ctl-schema.json#",
    "$schema": "http://iot.bzh/download/public/schema/json/ctl-schema.json#",
    "metadata": {
        "uid": "Other_Tests",
        "version": "1.0",
        "api": "aft-example",
        "info": "Binding made to test other bindings",
        "require": [
            "tested-api"
        ]
    },
    "testVerb": {
        "uid": "Complete",
        "info": "Launch all the tests",
        "action": "lua://AFT#_launch_test",
        "args": {
            "trace": "low-can",
            "files": [ "aftTest.lua", "mapis-tests.lua" ]
        }
    },
    "mapis": [{
        "uid": "low-can",
        "info": "Faked low-can API",
        "libs": "mapi_low-can.lua",
        "verbs": [
            {
                "uid": "subscribe",
                "info": "Subscribe to CAN signals events",
                "action": "lua://low-can#_subscribe"
            },
            {...},
            {
                "uid": "write",
                "info": "Write a CAN messages to the CAN bus.",
                "action": "lua://low-can#_write"
            }
        ],
        "events": [{
            "uid": "low-can/diagnostic_messages",
            "action": "lua://AFT#_evt_catcher_"
        },{
            "uid": "low-can/messages_engine_speed",
            "action": "lua://AFT#_evt_catcher_"
        },{
            "uid": "low-can/messages_vehicle_speed",
            "action": "lua://AFT#_evt_catcher_"
        }]
    }]
}
```

## The LUA test files

The test framework uses the LUA language to describe the tests.

You must be aware of two things when you write tests using
this framework: *test* and *assertions* functions.

- *Assertions* functions test an atomic operation result.
  (ie: `1+1 = 2`).
- *Test* functions represent a test. These functions represent a set of one
  or more *assertions* that must all succeed in order to valid the test.

The framework comes with several *test* and *assertion* functions that
allow verb calls and received events to be tested. Use these provided
*test* functions as a start.  If you
need more functions, use the ones that call a callback. If the test is more complex or
more comprehensive then *describe* your test function using *assert* functions.
Following is an example.

See the test framework functions ["References"](./5_References-functions.html) for a
comprehensive list of available *tests* and *assertions* functions:

### Tests example

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

    _AFT.testEvtGrpReceived("TestEventGroupReceived",{"hello/anEvent","hello/anotherEvent"},300000)
    _AFT.testEvtGrpNotReceived("TestEventGroupNotReceived",{"hello/anEvent","hello/anotherEvent"},300000)

    _AFT.testEvtReceived("testEvent", "hello/anEvent",300000)
    _AFT.testEvtReceived("testEventCb", "hello/anotherEvent",300000)

    _AFT.describe("myTestLabel", function()
      _AFT.assertEquals(false, false)
    end)
```
