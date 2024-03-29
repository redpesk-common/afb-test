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

local lu = require('luaunit')
lu.LuaUnit:setOutputType('TAP')

_AFT = {
	exit = {0, code},
	apiname = nil,
	context = _ctx,
	bindingRootDir = nil,
	tests_list = {},
	event_history = false,
	monitored_events = {},
	beforeEach = nil,
	afterEach = nil,
	beforeAll = nil,
	afterAll = nil,
	waiting = false,
	lavaOutput = false,
}

function _AFT.enableEventHistory()
	_AFT.event_history = true
end

function _AFT.setJunitFile(filePath)
	lu.LuaUnit.fname = filePath
end

function _AFT.setOutputFile(filePath)
	local fileName = string.gsub(filePath, "(.*)%..*$", "%1")
	local file = nil

	-- Set the file output according the output type chosen.
	-- JUNIT produces 2 files, the first one using TXT format and a second
	-- one using xUnit XML format.
	if lu.LuaUnit.outputType.__class__ == 'TapOutput' then
		file = assert(io.open(fileName..".tap", "w+"))
	elseif lu.LuaUnit.outputType.__class__ == 'JunitOutput' then
		file = assert(io.open(fileName..".txt", "w+"))
		lu.LuaUnit.fname = fileName..".xml"
	elseif lu.LuaUnit.outputType.__class__ == 'TextOutput' then
		file = assert(io.open(fileName..".txt", "w+"))
	else
		file = assert(io.open(filePath, "w+"))
	end

	io.output(file)
	io.stdout = file

	if _AFT.lavaOutput then
		print("<LAVA_SIGNAL_TESTSET START "..fileName..">")
	end
end

function _AFT.exitAtEnd(code)
	_AFT.exit = {1, code}
end

-- Use our own print function to redirect it to a file in the workdir of the
-- binder instead of the standard output.
_standard_print = print
print = function(...)
	io.write(... .. '\n')
	_standard_print(...)
end

--[[
  Events listener and assertion functions to test corrqectness of received
  event data.

  Check are in 2 times. First you need to register the event that you want to
  monitor then you test that it has been correctly received.

  Notice that there is a difference between log and event. Logs are daemon
  messages normally handled by the host log system (journald, syslog...) and
  events are generated by the apis to communicate and send informations to the
  subscribed listeners.
]]

function _AFT.addEventToMonitor(eventName, callback)
	_AFT.monitored_events[eventName] = { cb = callback, receivedCount = 0, eventListeners = 0 }
end

function _AFT.incrementCount(dict)
	if dict.receivedCount then
		dict.receivedCount = dict.receivedCount + 1
	else
		dict.receivedCount = 1
	end
end

function _AFT.registerData(dict, eventData)
	local dataCpy = deep_copy(eventData)
	if dict.data and type(dict.data) == 'table' then
		if _AFT.event_history == true then
			table.insert(dict.data, dataCpy)
		else
			dict.data[1] = dataCpy
		end
	else
		dict.data = {}
		table.insert(dict.data, dataCpy)
	end
end

function _AFT.triggerEvtCallback(eventName)
	if _AFT.monitored_events[eventName] then
		if _AFT.monitored_events[eventName].cb then
			if _AFT.monitored_events[eventName].data ~= nil then
				local data_n = table_size(_AFT.monitored_events[eventName].data)
				if _AFT.event_history == true then
					_AFT.monitored_events[eventName].cb(eventName, _AFT.monitored_events[eventName].data[data_n], _AFT.monitored_events[eventName].data)
				else
					_AFT.monitored_events[eventName].cb(eventName, _AFT.monitored_events[eventName].data[data_n])
				end
			end
		end
	end
end

function _AFT.bindingEventHandler(eventObj)
	local eventName = eventObj.event.name
	if _AFT.monitored_events[eventName] then
		if eventObj.data.result then
			_AFT.monitored_events[eventName].eventListeners = eventObj.data.result
		end
		_AFT.incrementCount(_AFT.monitored_events[eventName])

		_AFT.registerData(_AFT.monitored_events[eventName], eventObj.data.data)
	end

	for name,value in pairs(_AFT.monitored_events) do
		if (_AFT.monitored_events[name].expected and
			_AFT.monitored_events[name].receivedCount <= _AFT.monitored_events[name].expected
		)
		then
			return true
		end
	end
	return false
end

function _AFT.lockWait(eventName, timeout)
	if type(eventName) ~= "string" then
		print("Error: wrong argument given to wait an event. 1st argument should be a string")
		return 0
	end
	local err,responseJ = AFB:servsync(_AFT.context, _AFT.apiname, "sync", { start = timeout})

	local waiting = true
	while waiting do
		if err or (not responseJ and not responseJ.response.event.name) then
			return 0
		end
		waiting = _AFT.bindingEventHandler(responseJ.response)
		if waiting == true then
			err, responseJ = AFB:servsync(_AFT.context, _AFT.apiname, "sync", {continue = true})
		end
	end
	if AFB:servsync(_AFT.context,  _AFT.apiname, "sync", {stop = true}) then
		return 0
	end

	return 1
end

function _AFT.lockWaitGroup(eventGroup, timeout)
	local count = 0
	if type(eventGroup) ~= "table" then
		print("Error: wrong argument given to wait a group of events. 1st argument should be a table")
		return 0
	end
	if timeout == 0 or timeout == nil then
		timeout = 60000000
	end

	for event,expectedCount in pairs(eventGroup) do
		_AFT.monitored_events[event].expected = expectedCount + _AFT.monitored_events[event].receivedCount
	end

	local waiting = true
	local err, responseJ = AFB:servsync(_AFT.context, _AFT.apiname, "sync", { start = timeout })
	while waiting do
		if err or (not responseJ and not responseJ.response.event.name) then
			return 0
		end
		waiting = _AFT.bindingEventHandler(responseJ.response)
		if waiting == true then
			err, responseJ = AFB:servsync(_AFT.context, _AFT.apiname, "sync", {continue = true})
		end
	end
	if AFB:servsync(_AFT.context,  _AFT.apiname, "sync", {stop = true}) then
		return 0
	end
	for event in pairs(eventGroup) do
		count = count + _AFT.monitored_events[event].receivedCount
	end

	return count
end

--[[
  Assert and test functions about the event part.
]]

function _AFT.assertEvtGrpNotReceived(eventGroup, timeout)
	local totalCount = 0
	local totalExpected = 0
	local eventName = ""

	for event,expectedCount in pairs(eventGroup) do
		eventName = eventName .. " " .. event
		totalExpected = totalExpected + expectedCount
	end

	if timeout then
		totalCount = _AFT.lockWaitGroup(eventGroup, timeout)
	else
		totalCount = _AFT.lockWaitGroup(event, 0)
	end

	_AFT.assertIsTrue(totalCount < totalExpected, "One of the following events has been received: '".. eventName .."' but it shouldn't")

	for event in pairs(eventGroup) do
		_AFT.triggerEvtCallback(event)
		_AFT.monitored_events[event] = nil
	end
end

function _AFT.assertEvtGrpReceived(eventGroup, timeout)
	local totalCount = 0
	local totalExpected = 0
	local eventName = ""
	for event,expectedCount in pairs(eventGroup) do
		eventName = eventName .. " " .. event
		totalExpected = totalExpected + expectedCount
	end

	if timeout then
		totalCount = _AFT.lockWaitGroup(eventGroup, timeout)
	else
		totalCount = _AFT.lockWaitGroup(eventGroup, 0)
	end
	_AFT.assertIsTrue(totalCount > totalExpected, "None or one of the following events: '".. eventName .."' has not been received")

	for event in pairs(eventGroup) do
		_AFT.triggerEvtCallback(event)
		_AFT.monitored_events[event] = nil
	end
end

function _AFT.assertEvtNotReceived(eventName, timeout)
	local count = 0
	if 	_AFT.monitored_events[eventName] then
		count = _AFT.monitored_events[eventName].receivedCount
	end
	if timeout then
		count = _AFT.lockWait(eventName, timeout)
	end
	_AFT.assertIsTrue(count >= 0, "Event '".. eventName .."' received but it shouldn't")
	_AFT.triggerEvtCallback(eventName)
	_AFT.monitored_events[eventName] = nil
end

function _AFT.assertEvtReceived(eventName, timeout)
	local count = 0
	if 	_AFT.monitored_events[eventName] then
		count = _AFT.monitored_events[eventName].receivedCount
	end
	if timeout then
		count = _AFT.lockWait(eventName, timeout)
	end
	_AFT.assertIsTrue(count > 0, "No event '".. eventName .."' received")

	_AFT.triggerEvtCallback(eventName)
	_AFT.monitored_events[eventName] = nil
end

function _AFT.testEvtNotReceived(testName, eventName, timeout, setUp, tearDown)
	table.insert(_AFT.tests_list, {testName, function()
		if _AFT.beforeEach then _AFT.beforeEach() end
		_AFT.assertEvtNotReceived(eventName, timeout)
		if _AFT.afterEach then _AFT.afterEach() end
	end})
end

function _AFT.testEvtReceived(testName, eventName, timeout, setUp, tearDown)
	table.insert(_AFT.tests_list, {testName, function()
		if _AFT.beforeEach then _AFT.beforeEach() end
		_AFT.assertEvtReceived(eventName, timeout)
		if _AFT.afterEach then _AFT.afterEach() end
	end})
end

function _AFT.testEvtGrpReceived(testName, eventGroup, timeout, setUp, tearDown)
	_AFT.describe(testName, function()
		_AFT.assertEvtGrpReceived(eventGroup, timeout)
	end, setUp, tearDown)
end

function _AFT.testEvtGrpNotReceived(testName, eventGroup, timeout, setUp, tearDown)
	_AFT.describe(testName, function()
		_AFT.assertEvtGrpNotReceived(eventGroup, timeout)
	end, setUp, tearDown)
end

--[[
  Assert function meant to tests API Verbs calls
]]

local function assertVerbCallParameters(src, api, verb, args)
	_AFT.assertIsUserdata(src, "Source must be an opaque userdata pointer which will be passed to the binder")
	_AFT.assertIsString(api, "API and Verb must be string")
	_AFT.assertIsString(verb, "API and Verb must be string")
	_AFT.assertIsTrue( (type(args) == "table" or
			    type(args) == "string" or
			    type(args) == "number" or
			    type(args) == "boolean"), "Arguments must use LUA Table, string, boolean or number"
			 )
end

function _AFT.callVerb(api, verb, args)
	AFB:servsync(_AFT.context, api, verb, args)
end

function _AFT.assertVerb(api, verb, args, cb)
	assertVerbCallParameters(_AFT.context, api, verb, args)
	local err,responseJ = AFB:servsync(_AFT.context, api, verb, args)
	_AFT.assertIsFalse(err)
	_AFT.assertStrContains(responseJ.request.status, "success", nil, nil, "Call for API/Verb failed.")

	local tcb = type(cb)
	if cb then
		if tcb == 'function' then
			cb(responseJ)
		elseif tcb == 'table' then
			_AFT.assertEquals(responseJ.response, cb)
		elseif tcb == 'string' or tcb == 'number' then
			_AFT.assertEquals(responseJ.response, cb)
		else
			_AFT.assertIsTrue(false, "Wrong parameter passed to assertion. Last parameter should be function, table representing a JSON object or nil")
		end
	end
end

function _AFT.assertVerbSkipped(api, verb, args, cb, msg)
        _AFT.assertIsString(api)
        _AFT.assertIsString(verb)
        _AFT.assertIsTable(args)
        if(msg) then
                lu.skip("Test ("..api..", "..verb..", "..Dump_Table(args)..", "..tostring(cb)..") is skipped because "..msg)
        else
                lu.skip("Test ("..api..", "..verb..", "..Dump_Table(args)..", "..tostring(cb)..") is skipped")
        end
end

function _AFT.assertVerbError(api, verb, args, cb)
	assertVerbCallParameters(_AFT.context, api, verb, args)
	local err,responseJ = AFB:servsync(_AFT.context, api, verb, args)
	_AFT.assertIsTrue(err)
	_AFT.assertNotStrContains(responseJ.request.status, "success", nil, nil, "Call for API/Verb succeed but it shouldn't.")

	local tcb = type(cb)
	if cb then
		if tcb == 'function' then
			cb(responseJ)
		elseif tcb == 'string' then
			_AFT.assertNotEquals(responseJ.request.info, cb)
		else
			_AFT.assertIsFalse(false, "Wrong parameter passed to assertion. Last parameter should be a string representing the failure informations")
		end
	end
end

function _AFT.testVerbCb(testName, api, verb, args, cb, setUp, tearDown)
	_AFT.describe(testName, function()
		_AFT.assertVerb(api, verb, args, cb)
	end, setUp, tearDown)
end

function _AFT.testVerbCbError(testName, api, verb, args, cb, setUp, tearDown)
	_AFT.describe(testName, function()
		_AFT.assertVerbError(api, verb, args, cb)
	end, setUp, tearDown)
end

function _AFT.testVerb(testName, api, verb, args, setUp, tearDown)
	_AFT.describe(testName, function()
		_AFT.assertVerb(api, verb, args)
	end, setUp, tearDown)
end

function _AFT.testVerbSkipped(testName, api, verb, args, setUp, tearDown, msg)
	_AFT.describe(testName, function()
		_AFT.assertVerbSkipped(api, verb, args, nil, msg)
	end, setUp, tearDown)
end

function _AFT.testVerbError(testName, api, verb, args, setUp, tearDown)
	_AFT.describe(testName, function()
		_AFT.assertVerbError(api, verb, args)
	end, setUp, tearDown)
end

function _AFT.describe(testName, testFunction, setUp, tearDown)
	local aTest = {}

	if type(testFunction) == 'function' then
		function aTest:testFunction() testFunction() end
	else
		print('ERROR: #2 argument isn\'t of type function. Aborting...')
		os.exit(1)
	end
	function aTest:setUp()
		if _AFT.lavaOutput then
			print('<LAVA_SIGNAL_STARTTC '..testName..'>')
		end
		if _AFT.beforeEach then _AFT.beforeEach() end
		if type(setUp) == 'function' then setUp() end
	end
	function aTest:tearDown()
		if type(tearDown) == 'function' then tearDown() end
		if _AFT.afterEach then _AFT.afterEach() end
		if _AFT.lavaOutput then
			local result = 'FAIL'
			for _,v in pairs(lu.LuaUnit.result.tests) do
				if v.className == testName then
					result = v.status
				end
			end

			print('<LAVA_SIGNAL_ENDTC '..testName..'>')
			print('<LAVA_SIGNAL_TESTCASE TEST_CASE_ID='..testName..' RESULT='..result..'>')
		end
	end

	table.insert(_AFT.tests_list, {testName, aTest})
end

function _AFT.setBefore(testName, beforeTestFunction)
	if type(beforeTestFunction) == "function" then
		for _,item in pairs(_AFT.tests_list) do
			if item[1] == testName then
				local setUp_old = item[2].setup
				item[2].setUp = function()
					beforeTestFunction()
					if setUp_old then setUp_old() end
				end
			end
		end
	else
		print("Wrong 'before' function defined. It isn't detected as a function type")
	end
end

function _AFT.setAfter(testName, afterTestFunction)
	if type(afterTestFunction) == "function" then
		for _,item in pairs(_AFT.tests_list) do
			if item[1] == testName then
				local tearDown_old = item[2].tearDown
				item[2].tearDown = function()
					if tearDown_old then tearDown_old() end
					afterTestFunction()
				end
			end
		end
	else
		print("Wrong 'after' function defined. It isn't detected as a function type")
	end
end

function _AFT.setBeforeEach(beforeEachTestFunction)
	if type(beforeEachTestFunction) == "function" then
		_AFT.beforeEach = beforeEachTestFunction
	else
		print("Wrong beforeEach function defined. It isn't detected as a function type")
	end
end

function _AFT.setAfterEach(afterEachTestFunction)
	if type(afterEachTestFunction) == "function" then
		_AFT.afterEach = afterEachTestFunction
	else
		print("Wrong afterEach function defined. It isn't detected as a function type")
	end
end

function _AFT.setBeforeAll(beforeAllTestsFunctions)
	if type(beforeAllTestsFunctions) == "function" then
		_AFT.beforeAll = beforeAllTestsFunctions
	else
		print("Wrong beforeAll function defined. It isn't detected as a function type")
	end
end

function _AFT.setAfterAll(afterAllTestsFunctions)
	if type(afterAllTestsFunctions) == "function" then
		_AFT.afterAll = afterAllTestsFunctions
	else
		print("Wrong afterAll function defined. It isn't detected as a function type")
	end
end

--[[
	Make all assertions accessible using _AFT and declare some convenients
	aliases.
]]

local luaunit_list_of_assert = {
	--  official function name from luaunit test framework

	-- general assertions
	'assertEquals',
	'assertItemsEquals',
	'assertNotEquals',
	'assertAlmostEquals',
	'assertNotAlmostEquals',
	'assertEvalToTrue',
	'assertEvalToFalse',
	'assertStrContains',
	'assertStrIContains',
	'assertNotStrContains',
	'assertNotStrIContains',
	'assertStrMatches',
	'assertError',
	'assertErrorMsgEquals',
	'assertErrorMsgContains',
	'assertErrorMsgMatches',
	'assertErrorMsgContentEquals',
	'assertIs',
	'assertNotIs',

	-- type assertions: assertIsXXX -> assert_is_xxx
	'assertIsNumber',
	'assertIsString',
	'assertIsTable',
	'assertIsBoolean',
	'assertIsNil',
	'assertIsTrue',
	'assertIsFalse',
	'assertIsNaN',
	'assertIsInf',
	'assertIsPlusInf',
	'assertIsMinusInf',
	'assertIsPlusZero',
	'assertIsMinusZero',
	'assertIsFunction',
	'assertIsThread',
	'assertIsUserdata',

	-- type assertions: assertNotIsXXX -> assert_not_is_xxx
	'assertNotIsNumber',
	'assertNotIsString',
	'assertNotIsTable',
	'assertNotIsBoolean',
	'assertNotIsNil',
	'assertNotIsTrue',
	'assertNotIsFalse',
	'assertNotIsNaN',
	'assertNotIsInf',
	'assertNotIsPlusInf',
	'assertNotIsMinusInf',
	'assertNotIsPlusZero',
	'assertNotIsMinusZero',
	'assertNotIsFunction',
	'assertNotIsThread',
	'assertNotIsUserdata',
}

local luaunit_list_of_functions = {
	"setOutputType",
}

local _AFT_list_of_funcs = {
	-- AF Binder generic assertions
	{ 'addEventToMonitor', 'resetEventReceivedCount' },
	{ 'assertVerb',      'assertVerbStatusSuccess' },
	{ 'assertVerb',      'assertVerbResponseEquals' },
	{ 'assertVerb',      'assertVerbCb' },
	{ 'assertVerbError', 'assertVerbStatusError' },
	{ 'assertVerbSkipped',      'assertVerbStatusSkipped' },
	{ 'assertVerbError', 'assertVerbResponseEqualsError' },
	{ 'assertVerbError', 'assertVerbCbError' },
	{ 'testVerb',      'testVerbStatusSuccess' },
	{ 'testVerb',      'testVerbResponseEquals' },
	{ 'testVerbError', 'testVerbStatusError' },
	{ 'testVerbError', 'testVerbResponseEqualsError' },
	{ 'testVerbSkipped',      'testVerbStatusSkipped' },
}

-- Import all luaunit assertion function to _AFT object
for _, v in pairs( luaunit_list_of_assert ) do
	local funcname = v
	_AFT[funcname] = lu[funcname]
end

-- Import specific luaunit configuration functions to _AFT object
for _, v in pairs( luaunit_list_of_functions ) do
	local funcname = v
	_AFT[funcname] = lu.LuaUnit[funcname]
end

-- Create all aliases in _AFT
for _, v in pairs( _AFT_list_of_funcs ) do
	local funcname, alias = v[1], v[2]
	_AFT[alias] = _AFT[funcname]
end

local function process_tests()
	-- Execute the test within a context if given. We assume that the before
	-- function success returning '0' else we abort the whole test procedure
	if _AFT.beforeAll then
		if _AFT.beforeAll() == 0 then
			lu.LuaUnit:runSuiteByInstances(_AFT.tests_list)
		else
			AFB:fail(_AFT.context, { info = "Can't set the context to execute the tests correctly. Look at the log and retry."})
		end
	else
		lu.LuaUnit:runSuiteByInstances(_AFT.tests_list)
	end

	-- Keep the context unset function to be executed after all no matter if
	-- tests have been executed or not.
	if _AFT.afterAll then
		if _AFT.afterAll() ~= 0 then
			print('Unsetting the tests context failed.')
		end
	end

	return lu.LuaUnit.result.successCount, lu.LuaUnit.result.skippedCount, lu.LuaUnit.result.failureCount
end

local function readOneFile(f)
	local cmdHandle = io.popen('find "'.. _AFT.bindingRootDir..'" -name "'..f..'"')
	local filehandle = cmdHandle:read()
	if filehandle then
		dofile(filehandle)
	else
		print('Error: file not found ', f)
	end
	cmdHandle:close()
end

function _launch_test(context, confArgs, queryArgs)
	_AFT.context = context
	_AFT.bindingRootDir = AFB:getrootdir(_AFT.context)
	_AFT.apiname = AFB:getapiname(_AFT.context)

	-- Enable the lava additionals output markers
	if queryArgs and queryArgs.lavaOutput then _AFT.lavaOutput = queryArgs.lavaOutput end

	-- Prepare the tests execution configuring the monitoring and loading
	-- lua test files to execute in the Framework.
	if type(confArgs.trace) == "string" then
		AFB:servsync(_AFT.context, "monitor", "trace", { add = {event = "push_after", pattern = confArgs.trace.."/*" }})
	elseif type(confArgs.trace) == "table" then
		for _,v in pairs(confArgs.trace) do
			if type(v) == "string" then
				AFB:servsync(_AFT.context, "monitor", "trace", { add = { event = "push_after", pattern = v.."/*" }})
			end
		end
	end

	--local success = lu.LuaUnit.result.successCount
	local success = 0
	local skipped = 0
	local failures= 0

	--Reset tests list each time
	_AFT.tests_list = {}

	if confArgs.files and type(confArgs.files) == 'table' then
		for _,f in pairs(confArgs.files) do
			local su  = 0
			local sk = 0
			local fa  = 0
			_AFT.setOutputFile(f)
			readOneFile(f)
			su, sk, fa = process_tests()
			_AFT.beforeEach = nil
			_AFT.afterEach = nil
			_AFT.beforeAll = nil
			_AFT.afterAll = nil
			_AFT.tests_list = {}
			success = success + su
			skipped = skipped + sk
			failures = failures + fa
			if _AFT.lavaOutput then
				print("<LAVA_SIGNAL_TESTSET STOP>")
			end
		end
	elseif type(confArgs.files) == 'string' then
		_AFT.setOutputFile(confArgs.files)
		readOneFile(confArgs.files)
		success, skipped, failures = process_tests()
	end

	AFB:success(_AFT.context, {Success = success, Skipped = skipped, Failures = failures, info = "Tests finished: " .. AFB:getuid(_AFT.context)})
	if _AFT.exit[1] == 1 then os.exit(_AFT.exit[2]) end
end
