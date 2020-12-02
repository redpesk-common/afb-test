# C API Functions

## Binding Test functions

* **_AFT.testVerbStatusSuccess(testName, api, verb, args, setUp, tearDown)**

    Simply test that the call of a verb successfully returns.

    *setUp* and *tearDown* are functions that can be added to your context,
    it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**,
    *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()**
    (if set) functions, *tearDown* will be ran after your *testFunction* and
    **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbStatusError(testName, api, verb, args, setUp, tearDown)**

    The inverse than above.

    *setUp* and *tearDown* are functions that can be added to your context,
    it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**,
    *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()**
    (if set) functions, *tearDown* will be ran after your *testFunction* and
    **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbStatusSkipped(testName, api, verb, args, setUp, tearDown, msg)**

    Skip a test.

    *msg* is a message to indicate the reason why the test is skip,
    it must contain your test name if you want to parse the output.
    *setUp* and *tearDown* are functions that can be added to your context,
    it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**,
    *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()**
    (if set) functions, *tearDown* will be ran after your *testFunction* and
    **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbResponseEquals(testName, api, verb, args, expectedResponse, setUp, tearDown)**

    Test that the call of a verb successfully returns and that verb's response
    is equals to the *expectedResponse*.

    *setUp* and *tearDown* are functions that can be added to your context,
    it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp*
    will be ran before your *testFunction* and **_AFT.beforeEach()** (if set)
    functions, *tearDown* will be ran after your *testFunction* and
    **_AFT.afterEach()**  (if set) functions.

* **_AFT.testVerbResponseEqualsError(testName, api, verb, args, expectedResponse, setUp, tearDown)**

    The inverse than above.

    *setUp* and *tearDown* are functions that can be added to your context, it works
    just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran
    before your *testFunction* and **_AFT.beforeEach()** (if set) functions,
    *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if
    set) functions.

* **_AFT.testVerbCb(testName, api, verb, args, expectedResponse, callback, setUp, tearDown)**

    Test the call of a verb with a custom callback. From this callback you
    will need to make some assertions on what you need (verb JSON return object
    content mainly).

    If you don't need to test the response simply specify an empty LUA table.

    *setUp* and *tearDown* are functions that can be added to your context, it works
    just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran
    before your *testFunction* and **_AFT.beforeEach()** (if set) functions,
    *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if
    set) functions.

* **_AFT.testVerbCbError(testName, api, verb, args, expectedResponse, callback, setUp, tearDown)**

    Should return success on failure.

    *setUp* and *tearDown* are functions that can be added to your context, it works
    just like  **_AFT.beforeEach()** and **_AFT.afterEach()**, *setUp* will be ran
    before your *testFunction* and **_AFT.beforeEach()** (if set) functions,
    *tearDown* will be ran after your *testFunction* and **_AFT.afterEach()**  (if
    set) functions.

* **_AFT.testEvtReceived(testName, eventName, timeout, setUp, tearDown)**

    Prior to be able to check that an event has been received, you have to
    register the event with the test framework using **_AFT.addEventToMonitor**
    function.

    Check if an event has been correctly received in time (timeout in µs). An event
    name use the application framework naming scheme: **api/event_name**.

* **_AFT.testEvtNotReceived(testName, eventName, timeout, setUp, tearDown)**

    Prior to be able to check that an event has not been received, you have to
    register the event with the test framework using **_AFT.addEventToMonitor**
    function.

    Check if an event has not been correctly received in time (timeout in µs). An
    event name use the application framework naming scheme: **api/event_name**.

* **_AFT.testGrpEvtReceived(testName, eventGrp, timeout, setUp, tearDown)**

    Prior to be able to check that a group of event (a table of event) has been
    received, you have to register the event with the test framework using
    **_AFT.addEventToMonitor** function.

    The table has to have this format:
```lua
    eventGrp = {["api/event_name_1"]=1,["api/event_name_2"]=2,["api/event_name_3"]=5}
```
    As you can see, in the table, event names are table keys and the value stored are
    the number of time that the events have to be received.

    Check if events has been correctly received in time (timeout in µs). An
    event name use the application framework naming scheme: **api/event_name**.

## Binding Assert functions

* **_AFT.assertVerbStatusSuccess(api, verb, args)**

    Simply test that the call of a verb successfully returns.

* **_AFT.assertVerbStatusError(api, verb, args)**

    The inverse than above.

* **_AFT.assertVerbStatusSkipped(api, verb, args, msg)**

    Skip a test.

    *msg* must contain your test name if you want to parse the output.

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

    Check if an event has been correctly received in time (timeout in µs).
    An event name use the application framework naming scheme: **api/event_name**.

* **_AFT.assertEvtNotReceived(eventName, timeout)**

    Prior to be able to check that an event has been received, you have to
    register the event with the test framework using **_AFT.addEventToMonitor**
    function.

    Check if an event has been correctly received in time (timeout in µs).
    An event name use the application framework naming scheme: **api/event_name**.

* **_AFT.assertGrpEvtReceived(eventGrp, timeout)**

    Prior to be able to check that a group of event (a table of event) has been
    received, you have to register the event with the test framework using
    **_AFT.addEventToMonitor** function.

    The table has to have this format:
 ```lua
    eventGrp = {["api/event_name_1"]=1,["api/event_name_2"]=2,["api/event_name_3"]=5}
 ```
    As you can see, in the table, event names are table keys and the value stored are
    the number of time that the events have to be received.

    Check if events has been correctly received in time (timeout in µs).
    An event name use the application framework naming scheme: **api/event_name**.

## Test Framework functions

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

    Set the **_AFT.beforeEach()** function which is used to run the *function*
    before each tests.

* **_AFT.setAfterEach(function)**

    Set the **_AFT.afterEach()** function which is used to run the *function*
    after each tests.

* **_AFT.setBeforeAll(function)**

    Set the **_AFT.beforeAll()** function which is used to run the *function*
    before all tests. If the given function is successful it has to return 0
    else it will return an error.

* **_AFT.setAfterAll(function)**

    Set the **_AFT.afterAll()** function which is used to run the *function*
    after all tests. If the given function is successful it has to return 0
    else it will return an error.

* **_AFT.describe(testName, testFunction, setUp, tearDown)**

    Give a context to a custom test. *testFunction* will be given the name
    provided by *testName* and will be tested.

    *setUp* and *tearDown* are functions that can be added to your context,
    it works just like  **_AFT.beforeEach()** and **_AFT.afterEach()**,
    *setUp* will be ran before your *testFunction* and **_AFT.beforeEach()**
    (if set) functions, *tearDown* will be ran after your *testFunction* and
    **_AFT.afterEach()**  (if set) functions.

* **_AFT.setBefore(testName, beforeTestFunction)**

    Set a function to be ran at the beginning of the given *testName* function.

```lua
    _AFT.testVerbStatusSuccess('testPingSuccess','hello', 'ping', {})
    _AFT.setBefore("testPingSuccess",function() print("~~~~~ Begin testPingSuccess ~~~~~") end)
    _AFT.setAfter("testPingSuccess",function() print("~~~~~ End testPingSuccess ~~~~~") end)
```

* **_AFT.setBefore(testName, beforeTestFunction)**

    Set a function to be ran at the end of the given *testName* function.