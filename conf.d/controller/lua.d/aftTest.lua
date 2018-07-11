--[[
    Copyright (C) 2018 "IoT.bzh"
    Author Romain Forlot <romain.forlot@iot.bzh>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


    NOTE: strict mode: every global variables should be prefixed by '_'
--]]

_AFT.setBeforeEach(function() print("~~~~~ Begin Test ~~~~~") end)
_AFT.setAfterEach(function() print("~~~~~ End Test ~~~~~") end)

_AFT.setBeforeAll(function() print("~~~~~~~~~~ BEGIN ALL TESTS ~~~~~~~~~~") return 0 end)
_AFT.setAfterAll(function() print("~~~~~~~~~~ END ALL TESTS ~~~~~~~~~~") return 0 end)

_AFT.setBefore("testAssertNotEquals",function() print("~~~~~ Begin Test AssertNotEquals ~~~~~") end)
_AFT.setAfter("testAssertNotEquals",function() print("~~~~~ End Test AssertNotEquals ~~~~~") end)


local corout = coroutine.create( print )

_AFT.describe("testAssertEquals", function() _AFT.assertEquals(false, false) end,function() print("~~~~~ Begin Test Assert Equals ~~~~~") end,function() print("~~~~~ End Test Assert Equals ~~~~~") end)
_AFT.describe("testAssertNotEquals", function()  _AFT.assertNotEquals(true,false) end)
_AFT.describe("testAssertItemsEquals", function()	_AFT.assertItemsEquals({1,2,3},{3,1,2}) end)
_AFT.describe("testAssertAlmostEquals", function()	_AFT.assertAlmostEquals(1.25 ,1.5,0.5) end)
_AFT.describe("testAssertNotAlmostEquals", function()	_AFT.assertNotAlmostEquals(1.25,1.5,0.125) end)
_AFT.describe("testAssertEvalToTrue", function()	_AFT.assertEvalToTrue(true) end)
_AFT.describe("testAssertEvalToFalse", function()  _AFT.assertEvalToFalse(false) end)

_AFT.describe("testAssertStrContains", function()  _AFT.assertStrContains("Hello I'm a string","string") end)
_AFT.describe("testAssertStrContains", function()  _AFT.assertStrContains("Hello I'm a second string","second",5) end)

_AFT.describe("testAssertStrIContains", function()  _AFT.assertStrIContains("Hello I'm another string","I'm") end)

_AFT.describe("testAssertNotStrContains", function()  _AFT.assertNotStrContains("Hello it's me again, the other string","banana") end)
_AFT.describe("testAssertNotStrContains", function()  _AFT.assertNotStrContains("Hello it's me again, the other string","banana",8) end)

_AFT.describe("testAssertNotStrIContains", function()  _AFT.assertNotStrIContains("Hello it's not me this time !","trebuchet") end)

_AFT.describe("testAssertStrMatches", function()  _AFT.assertStrMatches("Automotive Grade Linux","Automotive Grade Linux") end)
_AFT.describe("testAssertStrMatches", function()  _AFT.assertStrMatches("Automotive Grade Linux from IoT.bzh","Automotive Grade Linux",1,22) end)
_AFT.describe("testAssertError", function()  _AFT.assertError(_AFT.assertEquals(true,true)) end)

_AFT.describe("testAssertErrorMsgEquals", function()  _AFT.assertErrorMsgEquals("attempt to call a nil value",
																									                              _AFT.assertStrMatches("test assertErrorMsgEquals","test",1,4)) end)
_AFT.describe("testAssertErrorMsgContains", function()	_AFT.assertErrorMsgContains("attempt to call",
																									                              _AFT.assertStrMatches("test assertErrorMsgEquals","test",1,4)) end)
_AFT.describe("testAssertErrorMsgMatches", function()	_AFT.assertErrorMsgMatches('attempt to call a nil value',
																								                              _AFT.assertStrMatches("test assertErrorMsgEquals","test",1,4)) end)

_AFT.describe("testAssertIs", function()	_AFT.assertIs('toto','to'..'to') end)
_AFT.describe("testAssertNotIs", function()  _AFT.assertNotIs({1,2},{1,2}) end)

_AFT.describe("testAssertIsNumber", function()  _AFT.assertIsNumber(23) end)
_AFT.describe("testAssertIsString", function()	_AFT.assertIsString("Lapin bihan") end)
_AFT.describe("testAssertIsTable", function()	_AFT.assertIsTable({1,2,3,4}) end)
_AFT.describe("testAssertIsBoolean", function()	_AFT.assertIsBoolean(true) end)
_AFT.describe("testAssertIsNil", function()	_AFT.assertIsNil(nil) end)
_AFT.describe("testAssertIsTrue", function()	_AFT.assertIsTrue(true) end)
_AFT.describe("testAssertIsFalse", function()	_AFT.assertIsFalse(false) end)
_AFT.describe("testAssertIsNaN", function()	_AFT.assertIsNaN(0/0) end)
_AFT.describe("testAssertIsInf", function()	_AFT.assertIsInf(1/0) end)
_AFT.describe("testAssertIsPlusInf", function()	_AFT.assertIsPlusInf(1/0) end)
_AFT.describe("testAssertIsMinusInf", function()	_AFT.assertIsMinusInf(-1/0) end)
_AFT.describe("testAssertIsPlusZero", function()	_AFT.assertIsPlusZero(1/(1/0)) end)
_AFT.describe("testAssertIsMinusZero", function()	_AFT.assertIsMinusZero(-1/(1/0)) end)
_AFT.describe("testAssertIsFunction", function()	_AFT.assertIsFunction(print) end)
_AFT.describe("testAssertIsThread", function()	_AFT.assertIsThread(corout) end)
_AFT.describe("testAssertIsUserdata", function()  _AFT.assertIsUserdata(_AFT.context) end)

_AFT.describe("testAssertNotIsNumber", function()  _AFT.assertNotIsNumber('a') end)
_AFT.describe("testAssertNotIsString", function()	_AFT.assertNotIsString(2) end)
_AFT.describe("testAssertNotIsTable", function()	_AFT.assertNotIsTable(2) end)
_AFT.describe("testAssertNotIsBoolean", function()	_AFT.assertNotIsBoolean(2) end)
_AFT.describe("testAssertNotIsNil", function()	_AFT.assertNotIsNil(2) end)
_AFT.describe("testAssertNotIsTrue", function()	_AFT.assertNotIsTrue(false) end)
_AFT.describe("testAssertNotIsFalse", function()	_AFT.assertNotIsFalse(true) end)
_AFT.describe("testAssertNotIsNaN", function()	_AFT.assertNotIsNaN(1) end)
_AFT.describe("testAssertNotIsInf", function()	_AFT.assertNotIsInf(2) end)
_AFT.describe("testAssertNotIsPlusInf", function()	_AFT.assertNotIsPlusInf(2) end)
_AFT.describe("testAssertNotIsMinusInf", function()	_AFT.assertNotIsMinusInf(2) end)
_AFT.describe("testAssertNotIsPlusZero", function()	_AFT.assertNotIsPlusZero(2) end)
_AFT.describe("testAssertNotIsMinusZero", function()	_AFT.assertNotIsMinusZero(2) end)
_AFT.describe("testAssertNotIsFunction", function()	_AFT.assertNotIsFunction(2) end)
_AFT.describe("testAssertNotIsThread", function()	_AFT.assertNotIsThread(2) end)
_AFT.describe("testAssertNotIsUserdata", function()	_AFT.assertNotIsUserdata(2) end)

function _callback(responseJ) _AFT.assertStrContains(responseJ.response, "Some String") end
function _callbackError(responseJ) _AFT.assertStrContains(responseJ.request.info, "Ping Binder Daemon fails") end

_AFT.describe("testAssertVerbStatusSuccess",function() _AFT.assertVerbStatusSuccess('hello', 'ping', {}) end)
_AFT.describe("testAssertVerbResponseEquals",function() _AFT.assertVerbResponseEquals('hello', 'ping', {},"Some String") end)
_AFT.describe("testAssertVerbCb",function() _AFT.assertVerbCb('hello', 'ping', {},_callback) end)
_AFT.describe("testAssertVerbStatusError",function() _AFT.assertVerbStatusError('hello', 'pingfail', {}) end)
_AFT.describe("testAssertVerbResponseEqualsError",function() _AFT.assertVerbResponseEqualsError('hello', 'pingfail', {},"Ping Binder Daemon fails") end)
_AFT.describe("testAssertVerbCbError",function() _AFT.assertVerbCbError('hello', 'pingfail', {},_callbackError) end)
