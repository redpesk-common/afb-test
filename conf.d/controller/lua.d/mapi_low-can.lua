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

function _subscribe(source, args)
  AFB:success(source)
end

function _unsubscribe(source, args)
  AFB:success(source)
end

function _get(source, args)
  local evtHandle1 = AFB:evtmake(source, 'messages_engine_speed')
  local evtHandle2 = AFB:evtmake(source, 'messages_vehicle_speed')
	if type(evtHandle1) == "userdata" and type(evtHandle2) == "userdata" then
		AFB:subscribe(source, evtHandle1)
    AFB:evtpush(source,evtHandle1,{value = 1234})
    AFB:subscribe(source, evtHandle2)
		AFB:evtpush(source,evtHandle2,{value = 5678})
	end
  AFB:success(source)
end

function _list(source, args)
  AFB:success(source)
end

function _auth(source, args)
  AFB:success(source)
end

function _write(source, args)
  AFB:success(source)
end
