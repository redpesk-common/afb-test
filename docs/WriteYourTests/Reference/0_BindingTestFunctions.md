# Binding Test functions

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

    Check if events has been correctly received in time (timeout in µs). An
    event name use the application framework naming scheme: **api/event_name**.

* **_AFT.testGrpEvtNotReceived(testName, eventGrp, timeout, setUp, tearDown)**

    Prior to be able to check that a group of event (a table of event) has not
    been received, you have to register the event with the test framework using
    **_AFT.addEventToMonitor** function.

    Check if event has not been correctly received in time (timeout in µs). An
    event name use the application framework naming scheme: **api/event_name**.