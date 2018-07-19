# Binding Assert functions

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

    Check if events has been correctly received in time (timeout in µs).
    An event name use the application framework naming scheme: **api/event_name**.

* **_AFT.assertGrpEvtNotReceived(eventGrp, timeout)**

    Prior to be able to check that a group of event (a table of event) has not
    been received, you have to register the event with the test framework using
    **_AFT.addEventToMonitor** function.

    Check if events has not been correctly received in time (timeout in µs).
    An event name use the application framework naming scheme: **api/event_name**.