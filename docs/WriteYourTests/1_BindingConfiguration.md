# Binding configuration

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