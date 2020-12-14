# References

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

## Lua Unit assertion functions

### General Assertions

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

    When comparing floating point numbers, strict equality does not work.
    Computer arithmetic is so that an operation that mathematically yields
    1.00000000 might yield 0.999999999999 in lua . That’s why you need an
    almost equals comparison, where you specify the error margin.

* **_AFT.assertNotAlmostEquals(actual, expected, margin)**

    Assert that two floating point numbers are not almost equal.

### Value assertions

* **_AFT.assertEvalToTrue(value)**

    Assert that a given value evals to true. Lua coercion rules are applied so
    that values like 0,"",1.17 succeed in this assertion. If provided, extra_msg
    is a string which will be printed along with the failure message.

* **_AFT.assertEvalToFalse(Value)**

    Assert that a given value eval to *false*. Lua coercion rules are applied so
    that *nil* and *false* succeed in this assertion. If provided, extra_msg is a
    string which will be printed along with the failure message.

* **_AFT.assertIsTrue(value)**

    Assert that a given value compares to true. Lua coercion rules are applied so
    that values like 0, "", 1.17 all compare to true.

* **_AFT.assertIsFalse(value)**

    Assert that a given value compares to false. Lua coercion rules are applied so
    that only nil and false all compare to false.

* **_AFT.assertIsNil(value)**

    Assert that a given value is nil .

* **_AFT.assertNotIsNil(value)**

    Assert that a given value is not *nil* . Lua coercion rules are applied
    so that values like ``0``, ``""``, ``false`` all validate the assertion.
    If provided, *extra_msg* is a string which will be printed along with the
    failure message.

* **_AFT.assertIs(actual, expected)**

    Assert that two variables are identical. For string, numbers, boolean and
    for nil, this gives the same result as assertEquals() . For the other types,
    identity means that the two variables refer to the same object.

    Example :

```lua
    s1='toto'
    s2='to'..'to'
    t1={1,2}
    t2={1,2}
    luaunit.assertIs(s1,s1) -- ok
    luaunit.assertIs(s1,s2) -- ok
    luaunit.assertIs(t1,t1) -- ok
    luaunit.assertIs(t1,t2) -- fail
```

* **_AFT.assertNotIs(actual, expected)**

    Assert that two variables are not identical, in the sense that they do not
    refer to the same value. See assertIs() for more details.

### Scientific assertions

>**Note**
>If you need to deal with value minus zero, be very careful because Lua versions
are inconsistent on how they treat the >syntax -0 : it creates either a plus
zero or a minus zero. Multiplying or dividing 0 by -1 also yields inconsistent >
results. The reliable way to create the -0 value is : minusZero = -1 / (1/0).

* **_AFT.assertIsNaN(value)**
    Assert that a given number is a *NaN* (Not a Number), according to the
    definition of IEEE-754_ . If provided, *extra_msg* is a string which will
    be printed along with the failure message.

* **_AFT.assertIsPlusInf(value)**

    Assert that a given number is *plus infinity*, according to the definition of
    IEEE-754_. If provided, *extra_msg* is a string which will be printed along
    with the failure message.

* **_AFT.assertIsMinusInf(value)**

    Assert that a given number is *minus infinity*, according to the definition of
    IEEE-754_. If provided, *extra_msg* is a string which will be printed along
    with the failure message.

* **_AFT.assertIsInf(value)**

    Assert that a given number is *infinity* (either positive or negative),
    according to the definition of IEEE-754_. If provided, *extra_msg* is a string
    which will be printed along with the failure message.

* **_AFT.assertIsPlusZero(value)**

    Assert that a given number is *+0*, according to the definition of IEEE-754_.
    The verification is done by dividing by the provided number and verifying
    that it yields *infinity* . If provided, *extra_msg* is a string which will
    be printed along with the failure message.

    Be careful when dealing with *+0* and *-0*, see note above

* **_AFT.assertIsMinusZero(value)**

    Assert that a given number is *-0*, according to the definition of IEEE-754_.
    The verification is done by dividing by the provided number and verifying that
    it yields *minus infinity* . If provided, *extra_msg* is a string which will
    be printed along with the failure message.

    Be careful when dealing with *+0* and *-0*

### String assertions

Assertions related to string and patterns.

* **_AFT.assertStrContains(str, sub[, useRe])**

    Assert that a string contains the given substring or pattern.

    By default, substring is searched in the string. If useRe is provided and is
    true, sub is treated as a pattern which is searched inside the string str.

* **_AFT.assertStrIContains(str, sub)**

    Assert that a string contains the given substring, irrespective of the case.

    Not that unlike assertStrcontains(), you can not search for a pattern.

* **_AFT.assertNotStrContains(str, sub, useRe)**

    Assert that a string does not contain a given substring or pattern.

    By default, substring is searched in the string. If useRe is provided and is
    true, sub is treated as a pattern which is searched inside the string str.

* **_AFT.assertNotStrIContains(str, sub)**

    Assert that a string does not contain the given substring, irrespective of
    the case.

    Not that unlike assertNotStrcontains(), you can not search for a pattern.

* **_AFT.assertStrMatches(str, pattern[, start[, final]])**

    Assert that a string matches the full pattern pattern.

    If start and final are not provided or are nil, the pattern must match the
    full string, from start to end. The functions allows to specify the expected
    start and end position of the pattern in the string.

### Error assertions

Error related assertions, to verify error generation and error messages.

* **_AFT.assertError(func, ...)**

    Assert that calling functions func with the arguments yields an error. If the function does not yield an error, the assertion fails.

    Note that the error message itself is not checked, which means that this function does not distinguish between the legitimate error that you expect and another error that might be triggered by mistake.

    The next functions provide a better approach to error testing, by checking explicitly the error message content.

>**Note**
>When testing LuaUnit, switching from assertError() to assertErrorMsgEquals() revealed quite a few bugs!

* **_AFT.assertErrorMsgEquals(expectedMsg, func, ...)**

    Assert that calling function func will generate exactly the given error message. If the function does not yield an error, or if the error message is not identical, the assertion fails.

    Be careful when using this function that error messages usually contain the file name and line number information of where the error was generated. This is usually inconvenient. To ignore the filename and line number information, you can either use a pattern with assertErrorMsgMatches() or simply check if the message contains a string with assertErrorMsgContains() .

* **_AFT.assertErrorMsgContains(partialMsg, func, ...)**

    Assert that calling function func will generate an error message containing partialMsg . If the function does not yield an error, or if the expected message is not contained in the error message, the assertion fails.

* **_AFT.assertErrorMsgMatches(expectedPattern, func, ...)**

    Assert that calling function func will generate an error message matching expectedPattern . If the function does not yield an error, or if the error message does not match the provided pattern the assertion fails.

    Note that matching is done from the start to the end of the error message. Be sure to escape magic all magic characters with % (like -+.?\*) .

### Type assertions

The following functions all perform type checking on their argument. If the
received value is not of the right type, the failure message will contain the
expected type, the received type and the received value to help you identify
better the problem.

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

### Table assertions

* **_AFT.assertItemsEquals(actual, expected)**

    Assert that two tables contain the same items, irrespective of their keys.

    This function is practical for example if you want to compare two lists but
    where items are not in the same order:

```lua
    luaunit.assertItemsEquals( {1,2,3}, {3,2,1} ) -- assertion succeeds
```
    The comparison is not recursive on the items: if any of the items are tables,
    they are compared using table equality (like as in assertEquals() ), where the
    key matters.

```lua
    luaunit.assertItemsEquals( {1,{2,3},4}, {4,{3,2,},1} ) -- assertion fails because {2,3} ~= {3,2}
```
