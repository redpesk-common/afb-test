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
	rm -f "$SOCKETSERVICE" 2> /dev/null
	trap '' EXIT SIGHUP SIGINT SIGABRT SIGTERM
	if [ $1 -ne 0 ]
	then
		[ -f "${LOGFILESERVICE}" ] && cat "${LOGFILESERVICE}"
		[ -f "${LOGFILETEST}" ] && cat "${LOGFILETEST}"
		if [[ $1 -eq 124 ]] || [[ $1 -eq 137 ]]
		then
			echo -e "Error: Test timed out. Try to use '-t' options to increase the timeout.\nError: Exit Code: $1"
		else
			echo -e "Error: Test launch failed.\nError: Exit Code: $1"
		fi
	else
		find "${TESTPACKAGEDIR}" -maxdepth 1 -name '*.tap' -exec cat {} \;
		find "${TESTPACKAGEDIR}" -maxdepth 1 -name '*.txt' -exec cat {} \;
		find "${TESTPACKAGEDIR}" -maxdepth 1 -name '*.xml' -a ! -name 'config.xml' -exec cat {} \;
		echo "Tests correctly launched."
	fi
	exit $1
}

function usage() {
	cat >&2 << EOF
Usage: $0 <binding-wgt-rootdir> <test-wgt-rootdir> [-m|--mode <SOLO|SERVICE>] [-t|--timeout <X>] [-l|--lavaoutput]
binding-wgt-rootdir: path to the test wgt file
test-wgt-rootdir: path to the test folder file
-m|--mode: SOLO (1 binder) or SERVICE (2 binders) (Default: SOLO)
-t|--timeout: timeout in second. (Default 3 seconds)
-l|--lavaoutput: Flags indicating the binding to add Lava special test markers.
EOF
}

BINDER=$(command -v afb-daemon)
AFBTEST="$(pkg-config --variable libdir afb-test)/aft.so"
PORT=1234
PORTSERVICE=$((PORT+1))
TOKEN=

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
	-d|--debug)
	DEBUGOUTPUT="TRUE"
	shift # past argument
	;;
	-l|--lavaoutput)
	LAVAOUTPUT="TRUE"
	shift # past argument
	;;
	-m|--mode)
	MODE="$2"
	shift # past argument
	shift # past value
	;;
	-t|--timeout)
	TIMEOUT="$2"
	shift # past argument
	shift # past value
	;;
	*)
	POSITIONAL+=("$1") # save it in an array for later
	shift # past argument
	;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "${DEBUGOUTPUT}" = "TRUE" ]
then
	set -x
fi

if [ "$1" ] && [ "$2" ]
then
	SERVICEPACKAGEDIR="$(readlink -f $1)"
	TESTPACKAGEDIR="$(readlink -f $2)"
else
	echo "Error: you did not specify either the binding folder location or test widget folder location."
	usage
	cleanNexit 1
fi

[ -z "$MODE" ] && MODE="SOLO"
[ -z "$TIMEOUT" ] && TIMEOUT=3

TESTCFGFILE=$(find "${TESTPACKAGEDIR}" -name "aft-*.json" -print | head -n1)
TESTAPINAME=$(grep '\"api\"' "${TESTCFGFILE}" | cut -d'"' -f4)
[ ! -f "${TESTPACKAGEDIR}/config.xml" ] && \
	echo "Error: you don't have the config.xml file. Please call 'make widget'" && \
	cleanNexit 5
TESTPROCNAME="afbd-$(grep -Eo 'id=".*" ' "${TESTPACKAGEDIR}/config.xml" | cut -d'=' -f2 | tr -d '" '| tr '[:upper:]' '[:lower:]')"

API=$(grep "provided-api" "${SERVICEPACKAGEDIR}/config.xml" -A1 2> /dev/null |  sed -r -e '1d' -e 's:.*"(.*)" v.*:\1:' 2> /dev/null)
[ -z "$API" ] && [ "$MODE" = "SERVICE" ] && \
	echo "Error: you doesn't have the config.xml file. Please call 'make widget'" && \
	cleanNexit 2

ENV_API=$(echo ${API} | sed 's:[^a-zA-Z0-9_]:_:g')
declare AFT_${ENV_API}_CONFIG_PATH="${SERVICEPACKAGEDIR}"
declare AFT_$(echo ${ENV_API} | sed 's:[^a-zA-Z0-9_]:_:g')_PLUGIN_PATH="${SERVICEPACKAGEDIR}"
export AFT_${ENV_API}_CONFIG_PATH
export AFT_${ENV_API}_PLUGIN_PATH
PROCNAME="afbd-$(grep -Eo 'id=".*" ' "${SERVICEPACKAGEDIR}/config.xml" | cut -d'=' -f2 | tr -d '" '| tr '[:upper:]' '[:lower:]')"
SOCKETSERVICE="/tmp/$API"

declare -a testVerb

if [[ $(jq -r '.testVerb|type' ${TESTCFGFILE}) == "array" ]]
then
        testVerbLength=$(jq '.testVerb|length' ${TESTCFGFILE})
        for (( idx=0; idx<testVerbLength; idx++ )) do
                testVerb[$idx]=$(jq -r ".testVerb[$idx].uid" ${TESTCFGFILE})
        done
else
        testVerb[0]=$(jq -r ".testVerb.uid" ${TESTCFGFILE})
fi

export AFT_CONFIG_PATH="${TESTPACKAGEDIR}"
export AFT_PLUGIN_PATH="${TESTPACKAGEDIR}"

LOGFILESERVICE="test-service.log"
LOGFILETEST="test.log"

testVerbLength=${#testVerb[@]}
for (( idx=0; idx<testVerbLength; idx++ )) do
	if [ "${LAVAOUTPUT}" ]
	then
		testVerbCalls="--call=${TESTAPINAME}/${testVerb[$idx]}:{\"lavaOutput\":true} ${testVerbCalls}"
	else
		testVerbCalls="--call=${TESTAPINAME}/${testVerb[$idx]}:{} ${testVerbCalls}"
	fi
done

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
			--ldpaths="${SERVICEPACKAGEDIR}" \
			--binding="${AFBTEST}" \
			$(echo -e "${testVerbCalls}") \
			--call="${TESTAPINAME}/exit:{}" \
			-vvv &> "${LOGFILETEST}"
elif [ ${MODE} = "SERVICE" ]
then
	pkill "$TESTPROCNAME"
	pkill "$PROCNAME"

	timeout -s 9 ${TIMEOUT} ${BINDER} --name="${PROCNAME}" \
				--workdir="${SERVICEPACKAGEDIR}" \
				--port=${PORTSERVICE} \
				--ldpaths=. \
				-vvv \
				--ws-server=unix:"${SOCKETSERVICE}" &> "${LOGFILESERVICE}" &

	sleep 0.3

	timeout -s 9 ${TIMEOUT} ${BINDER} --name="${TESTPROCNAME}" \
				--port="${PORT}" \
				--no-httpd \
				--tracereq=common \
				--token=${TOKEN} \
				--workdir="${TESTPACKAGEDIR}" \
				--binding="${AFBTEST}" \
				--ws-client=unix:"${SOCKETSERVICE}" \
				$(echo -e "${testVerbCalls}") \
				--call="${TESTAPINAME}/exit:{}" \
				-vvv &> "${LOGFILETEST}"
else
	echo "Error: No mode selected. Choose between SOLO or SERVICE"
	usage
	cleanNexit 3
fi

cleanNexit $?
