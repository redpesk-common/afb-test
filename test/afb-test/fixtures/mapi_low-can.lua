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

function _evtpush(source, context, val)
  local event = val[0]
  return AFB:evtpush(source, _evtHandles[event], val[1])
end

function _get(source, args)
  _evtHandles = {}
  _messageHandles = {}

  _evtHandles['messages_engine_speed'] = nil
  _evtHandles['messages_vehicle_speed'] = nil

  _messageHandles['messages_engine_speed'] = 1234
  _messageHandles['messages_vehicle_speed'] = 5678

  for k,v in pairs(_messageHandles) do
    if type(_evtHandles[k]) ~= "userdata" then
      _evt = AFB:evtmake(source, k)
      _evtHandles[k] = _evt
    end
    if type(_evtHandles[k]) == "userdata" then
      AFB:subscribe(source, _evtHandles[k])
      AFB:timerset(source, {uid="evtpush_"..k, delay=1, count=1}, "_evtpush", {k, v})
    end
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
