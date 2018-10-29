# Write the tests

## Create the test tree

At the root of your project, create a test dedicated directory that will hold
all your tests materials. A classic test tree looks like the following:

```tree
 test
 ├── CMakeLists.txt
 ├── etc
 │   ├── CMakeLists.txt
 │   └── aft-middlename.json
 ├── fixtures
 │   ├── CMakeLists.txt
 │   ├── helper.sh
 │   ├── data
 │   └── plugin.lua
 └── tests
     ├── CMakeLists.txt
     ├── test01.lua
     ├── test02.lua
     └── test03.lua
 ...
```

Here is a description of each subdirectory purpose:

- etc: holds the test binding configuration in a JSON file.
- fixtures: contains all external needed files to run your tests. This is mainly
 used to inject data or a plugin with the mock-up APIs code in a LUA or C plugin
- tests: Contains only the tests written in LUA for your binding.

## Create your configuration file

The configuration file describes your test api and how it launches the tests. A
test binding doesn't provide verbs and this configuration will describe the api
verb(s), mocked-up apis. Here are the `key` descriptions for this file:

### `metadata` section

- `uid`: A simple label mainly useful at debugging purpose
- `version` (optional): the test's version
- `info` (optional): self-explanatory
- `api`: the name that your test binding will take. Used to be the test api's
 name prefixed with `aft` (ie: `aft-<tested-api-name>`)
- `require`: the tested api's name. This key ensure that the tested api is
 correctly launched and initialized so the test binding could test it.

### `testVerb` section

- `uid`: the verb name
- `info` (optional): self-explanatory
- `action`: special string indicating which function to trigger when the verb is
 called. It will always be the same about the test binding.
- `args` section:
  - `trace`: the name of the tested api that you are going to test. This is
   needed to let the test binding tracing the tested api and retrieve through
   the binder monitoring feature `calls` and `events`.
  - `files`: A string or an array of strings of the LUA files with your tests.
   Only provide the file name without the path.

### `mapis`, stand for Mock-up api, section

- `uid`: the mocked up api's name
- `info` (optional): self explanatory
- `libs`: LUA script or C plugin file name

#### `verbs` section

Describe the implemented mocked up API verbs. Each verb is mapped to a function
name that will be executed at the verb call.

- `uid`: verb's name
- `info` (optional): self explanatory
- `action`: an URI string that point to a C plugin or LUA script's function that
 will be executed at the verb call. The format of the action URI is:
 `<lua|plugin|api>`://`<C plugin's name|api's name|lua script name>`#`<function|verb's name>`

#### `events` section

This section allows you to trigger a function when a described event is received
. It could be for any event which you need to apply modifications on it. You DO
NOT have to enumerate each possible events that the mocked up api would
generate, you could avoid this section if you do not want to execute a function
at events reception.

- `uid`: event's name (`<api>/<event-name>`)
- `info` (optional): self explanatory
- `action`: an URI string that point to a C plugin or LUA script's function that
 will be executed at the event reception. The format of the action URI is:
 `<lua|plugin|api>`://`<C plugin's name|api's name|lua script name>`#`<function|verb's name>`
 the action `lua://AFT#_evt_catcher_` is the default `afb-test` events listener.

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

and another example that mock-up the `low-can` api:

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

You have two different things to have in mind when you write your tests using
this framework: *test* and *assertions* functions.

- *Assertions* functions are meant to test an atomic operation result.
 (ie: `1+1 = 2` is an assertion)
- *Test* functions represent a test (Unbelievable), they represent a set of one
 or several *assertions* which are all needed to succeed to valid the test.

The framework comes with several *test* and *assertion* functions to simply be
able to test verb calls and events receiving. Use the *test* ones and if you
need more use the ones that call a callback. If the test is more complex or
more comprehensive then *describe* your test function using *assert* functions.
See the example below.

See the test framework functions [References](Reference/Introduction.md) for a
comprehensive list of *tests* and *assertions* functions available.

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
