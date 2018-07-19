# General Assertions

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