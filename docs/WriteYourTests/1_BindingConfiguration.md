# Test configuration

The file `aft-test.json` contains the controller binding configuration. Here,
you have to change or define the *files* key in the *args* object of the
*testVerb* section, *testVerb* is an array of verb definition which are
meant to launch different LUA test files.

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
        "api": "afTest",
        "info": "Binding made to test other bindings",
        "require": [
            "hello"
        ]
    },
    "testVerb": {
        "uid": "launch_all_tests",
        "info": "Launch all the tests",
        "action": "lua://AFT#_launch_test",
        "args": {
            "trace": "hello",
            "files": ["aftTest.lua","helloworld.lua"]
        }
    }
}
```

and another example which tests the low-can api:

```json
{
    "id": "http://iot.bzh/download/public/schema/json/ctl-schema.json#",
    "$schema": "http://iot.bzh/download/public/schema/json/ctl-schema.json#",
    "metadata": {
        "uid": "Test",
        "version": "1.0",
        "api": "aft-aftest",
        "info": "Binding made to test other bindings",
        "require": [
            "low-can"
        ]
    },
    "testVerb": {
        "uid": "launch_all_tests",
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
            {
                "uid": "unsubscribe",
                "info": "Unsubscribe previously suscribed signals.",
                "action": "lua://low-can#_unsubscribe"
            },
            {
                "uid": "get",
                "info": "get a current value of CAN message",
                "action": "lua://low-can#_get"
            },
            {
                "uid": "list",
                "info": "get a supported CAN message list",
                "action": "lua://low-can#_list"
            },
            {
                "uid": "auth",
                "info": "Authenticate session to be raise Level Of Assurance.",
                "action": "lua://low-can#_auth"
            },
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
