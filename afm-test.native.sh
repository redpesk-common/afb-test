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

trap "cleanNexit 1" SIGHUP SIGINT SIGABRT SIGTERM
cleanNexit() {
  rm -f $SOCKETSERVICE 2> /dev/null
  trap '' EXIT SIGHUP SIGINT SIGABRT SIGTERM
  [ $1 -ne 0 ] && echo "Error: Test launch failed. Code: $1" && cat ${LOGFILETEST} ${LOGFILESERVICE}
  exit $1
}

function usage() {
	cat >&2 << EOF
Usage: $0 <binding-wgt-rootdir> <test-wgt-rootdir> [mode] [timeout]
binding-wgt-rootdir: path to the test wgt file
test-wgt-rootdir: path to the test folder file
mode: SOLO (1 binder) or SERVICE (2 binders)
timeout: default 3 seconds
EOF
}

BINDER=$(command -v afb-daemon)
AFBTEST="$(pkg-config --variable libdir afb-test)/aft.so"
PORT=1234
PORTSERVICE=$((PORT+1))
TOKEN=

if [ "$1" ] && [ "$2" ]
then
	SERVICEPACKAGEDIR="$(readlink -f $1)"
	TESTPACKAGEDIR="$(readlink -f $2)"
else
	echo "Error: you did not specify either the binding folder location or test widget folder location."
	usage
	cleanNexit 1
fi

if [ "$3" ]
then
	MODE="$3"
else
	MODE="SOLO"
fi

if [ "$4" ]
then
	TIMEOUT=$4
else
	TIMEOUT=3
fi

TESTCFGFILE=$(find "${TESTPACKAGEDIR}" -name "aft-*.json" -print | head -n1)
TESTAPINAME=$(grep '\"api\"' "${TESTCFGFILE}" | cut -d'"' -f4)
[ ! -f "${TESTPACKAGEDIR}/config.xml" ] && \
	echo "Error: you don't have the config.xml file. Please call 'make widget'" && \
	cleanNexit 5
TESTPROCNAME="afbd-$(grep -Eo 'id=".*" ' ${TESTPACKAGEDIR}/config.xml | cut -d'=' -f2 | tr -d '" '| tr '[:upper:]' '[:lower:]')"

API=$(grep "provided-api" "${SERVICEPACKAGEDIR}/config.xml" -A1 2> /dev/null |  sed -r -e '1d' -e 's:.*"(.*)" v.*:\1:' 2> /dev/null)
[ -z "$API" ] && [ "$MODE" = "SERVICE" ] && \
	echo "Error: you doesn't have the config.xml file. Please call 'make widget'" && \
	cleanNexit 2

ENV_API=$(echo ${API} | sed 's:[^a-zA-Z0-9_]:_:g')
declare AFT_${ENV_API}_CONFIG_PATH="${SERVICEPACKAGEDIR}"
declare AFT_$(echo ${ENV_API} | sed 's:[^a-zA-Z0-9_]:_:g')_PLUGIN_PATH="${SERVICEPACKAGEDIR}"
export AFT_${ENV_API}_CONFIG_PATH
export AFT_${ENV_API}_PLUGIN_PATH
PROCNAME="afbd-$(grep -Eo 'id=".*" ' ${SERVICEPACKAGEDIR}/config.xml | cut -d'=' -f2 | tr -d '" '| tr '[:upper:]' '[:lower:]')"
SOCKETSERVICE="/tmp/$API"

export AFT_CONFIG_PATH="${TESTPACKAGEDIR}"
export AFT_PLUGIN_PATH="${TESTPACKAGEDIR}"

LOGFILESERVICE="test-service.log"
LOGFILETEST="test.log"

if [ ${MODE} = "SOLO" ]
then
	pkill "${TESTPROCNAME}"

	timeout -s 9 ${TIMEOUT} \
		${BINDER} --name="${TESTPROCNAME}" \
			--port="${PORT}" \
			--roothttp=. \
			--tracereq=common \
			--token=${TOKEN} \
			--workdir="${TESTPACKAGEDIR}" \
			--ldpaths=${SERVICEPACKAGEDIR} \
			--binding="${AFBTEST}" \
			--call="${TESTAPINAME}/launch_all_tests:{}" \
			--call="${TESTAPINAME}/exit:{}" \
			-vvv &> ${LOGFILETEST}
elif [ ${MODE} = "SERVICE" ]
then
	pkill "$TESTPROCNAME"
	pkill "$PROCNAME"

	timeout -s 9 ${TIMEOUT} ${BINDER} --name="${PROCNAME}" \
				--workdir="${SERVICEPACKAGEDIR}" \
				--port=${PORTSERVICE} \
				--ldpaths=. \
				-vvv \
				--ws-server=unix:${SOCKETSERVICE} &> ${LOGFILESERVICE} &

	sleep 0.3

	timeout -s 9 ${TIMEOUT} ${BINDER} --name="${TESTPROCNAME}" \
				--port="${PORT}" \
				--no-httpd \
				--tracereq=common \
				--token=${TOKEN} \
				--workdir="${TESTPACKAGEDIR}" \
				--binding="${AFBTEST}" \
				--ws-client=unix:${SOCKETSERVICE} \
				--call="${TESTAPINAME}/launch_all_tests:{}" \
				--call="${TESTAPINAME}/exit:{}" \
				-vvv &> ${LOGFILETEST}
else
	echo "Error: No mode selected. Choose between SOLO or SERVICE"
	usage
	cleanNexit 3
fi

cleanNexit $?
