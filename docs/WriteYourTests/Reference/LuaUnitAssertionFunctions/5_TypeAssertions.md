# Type assertions

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