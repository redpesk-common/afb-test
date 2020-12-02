# Lua API Functions

## General Assertions

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

## Value assertions

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

## Scientific assertions

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

## String assertions

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

## Error assertions

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

## Type assertions

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

## Table assertions

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
