#!/bin/bash

###########################################################################
# Copyright (C) 2017, 2018 IoT.bzh
#
# Author: Romain Forlot <romain.forlot@iot.bzh>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################

trap cleanup SIGTERM SIGINT SIGABRT SIGHUP

function cleanup() {
	afm-util kill $pid >&2
	afm-util remove $APP >&2
	exit 1
}

 function usage() {
cat >&2 << EOF
Usage: $0 <path>
path: path to the test wgt file
EOF
}

function error() {
	echo "FAIL: $*" >&2
	cleanup
}
function info() {
	echo "PASS: $*" >&2
}

# check application name passed as first arg
WGT=$1
[[ -z "$WGT" ]] && { usage; exit 0;}
[[ ! -f "$WGT" ]] && { usage; exit 0;}

INSTALL=$(afm-util install $WGT)
APP=$(echo $INSTALL | jq -r .added)
[[ "$APP" == "null" ]] && error "Widget contains error. Abort"
APP_HOME=${HOME}/app-data/$(echo ${APP} |cut -d'@' -f1)

# ask appfw to start application
pid=$(afm-util start $APP)
[[ -z "$pid" || ! -e "/proc/$pid" ]] && error "Failed to start application $APP"
info "$APP started with pid=$pid"

kill -0 $pid
RUNNING=$?
while [[ $RUNNING -eq 0 ]]
do
	kill -0 $pid
	RUNNING=$?
	sleep 0.2
done

# Terminate the App
afm-util kill $pid >&2
afm-util remove $APP >&2

# Little sed script making compliant the output of test results for ptest.
sed -r -e '/^# (S| +)/d' -e '1d' -e 's:^ok +([0-9]+)\t+(.*):PASS\: \1 \2:' -e 's:^not ok +([0-9]+)\t+(.*):FAIL\: \1 \2:' ${APP_HOME}/test_results.log

info "$APP killed and removed"
