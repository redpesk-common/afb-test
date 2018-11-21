# String assertions

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