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

_AFT.testVerbStatusSuccess("TestListverb", "low-can", "list", {})
_AFT.testVerbStatusSuccess("TestGetVerb", "low-can", "get", { event = "engine.speed"})

_AFT.describe("Test_turning_on", function()
    local evt1 = "low-can/messages_engine_speed"
    local evt2 = "low-can/messages_vehicle_speed"
    _AFT.addEventToMonitor(evt1)
    _AFT.addEventToMonitor(evt2)

    _AFT.assertVerb("low-can", "get", {})

    _AFT.assertEvtGrpReceived({[evt1] = 1, [evt2] = 1})
end)


_AFT.describe("testLockWait",function()
    local evt1 = "low-can/messages_engine"
    local evt2 = "low-can/messages_engine_not_receive"
    local timeout = 2000000
    _AFT.addEventToMonitor(evt1)
    local start = os.time() * 1000000
    _AFT.assertEvtNotReceived(evt2, timeout)
    local stop = os.time() * 1000000
    _AFT.assertIsTrue( (stop - start) >= timeout, "Timeout not reached, LockWait feature is not working." )
  end, nil, nil)
