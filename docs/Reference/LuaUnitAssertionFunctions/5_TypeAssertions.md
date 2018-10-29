# Type assertions

The following functions all perform type checking on their argument. If the
received value is not of the right type, the failure message will contain the
expected type, the received type and the received value to help you identify
better the problem.

* **_AFT.assertIsNumber(value)**

    Assert that the argument is a number (integer or float)
    
    ```lua
    _AFT.assertIsNumber(1)
    ```

* **_AFT.assertIsString(value)**

    Assert that the argument is a string.
    
    ```lua
    _AFT.assertIsString("string")
    ```

* **_AFT.assertIsTable(value)**

    Assert that the argument is a table.
    
    ```lua
    _AFT.assertIsTable({key = "value"})
    ```

* **_AFT.assertIsBoolean(value)**

    Assert that the argument is a boolean.
    
    ```lua
    _AFT.assertIsBoolean(false)
    ```

* **_AFT.assertIsFunction(value)**

    Assert that the argument is a function.
    
    ```lua
    _AFT.assertIsFunction(function() print("HELLO WORLD!") end)
    ```

* **_AFT.assertIsUserdata(value)**

    Assert that the argument is a userdata.
    
    ```lua
    _AFT.assertIsUserdata(someCvariableImportedAsUserDataInLua)
    ```

* **_AFT.assertIsThread(value)**

    Assert that the argument is a coroutine (an object with type thread ).
    
    ```lua
    local corout = coroutine.create( print )

    _AFT.assertIsUserdata(corout)
    ```

* **_AFT.assertNotIsThread(value)**

    Assert that the argument is a not coroutine (an object with type thread ).
    
    ```lua
    _AFT.assertNotIsThread(2)
    ```