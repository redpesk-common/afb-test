#!/bin/bash

###########################################################################
# Copyright (C) 2017, 2018, 2020 IoT.bzh
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
	for A in ${APIs};do
		rm -f /tmp/${A} 2> /dev/null
	done
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
Usage: $0 <binding-wgt-rootdir> <test-wgt-rootdir> [-m|--mode <SOLO|SERVICE>] [-t|--timeout <X>] [-l|--lavaoutput] [-c|--coverage]
binding-wgt-rootdir: path to the test wgt file
test-wgt-rootdir: path to the test folder file
-m|--mode: SOLO (1 binder) or SERVICE (2 binders) (Default: SOLO)
-t|--timeout: timeout in second. (Default 3 seconds)
-l|--lavaoutput: Flags indicating the binding to add Lava special test markers.
-c|--coverage: Deploy coverage reports once the tests are completed.
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
	-c|--coverage)
	COVERAGE="TRUE"
	shift # past argument
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
COVERAGE_PATH="coverage"

TESTCFGFILE=$(find "${TESTPACKAGEDIR}" -name "aft-*.json" -print | head -n1)
TESTAPINAME=$(grep '\"api\"' "${TESTCFGFILE}" | cut -d'"' -f4)
[ ! -f "${TESTPACKAGEDIR}/config.xml" ] && \
	echo "Error: you don't have the config.xml file. Please call 'make widget'" && \
	cleanNexit 5
TESTPROCNAME="afbd-$(grep -Eo 'id=".*" ' "${TESTPACKAGEDIR}/config.xml" | cut -d'=' -f2 | tr -d '" '| tr '[:upper:]' '[:lower:]')"

APIs=$(sed '/feature.*provided-api/,/feature/!d' "${SERVICEPACKAGEDIR}/config.xml" | grep -v feature| sed -r -e 's:.*"(.*)" v.*:\1:')
API=$(echo $APIs | cut -d" " -f1)

[ -z "$API" ] && [ "$MODE" = "SERVICE" ] && \
	echo "Error: you doesn't have the config.xml file. Please call 'make widget'" && \
	cleanNexit 2

ENV_API=$(echo ${API} | sed 's:[^a-zA-Z0-9_]:_:g')
declare AFT_${ENV_API}_CONFIG_PATH="${SERVICEPACKAGEDIR}"
declare AFT_$(echo ${ENV_API} | sed 's:[^a-zA-Z0-9_]:_:g')_PLUGIN_PATH="${SERVICEPACKAGEDIR}"
export AFT_${ENV_API}_CONFIG_PATH
export AFT_${ENV_API}_PLUGIN_PATH
PROCNAME="afbd-$(grep -Eo 'id=".*" ' "${SERVICEPACKAGEDIR}/config.xml" | cut -d'=' -f2 | tr -d '" '| tr '[:upper:]' '[:lower:]')"
SOCKETCLIENT="";
SOCKETSERVER="";
for A in ${APIs};do
  SOCKETCLIENT="${SOCKETCLIENT} --ws-client=unix:/tmp/${A} ";
  SOCKETSERVER="${SOCKETSERVER} --ws-server=unix:/tmp/${A} ";
done

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
			-vvv \
			&> "${LOGFILETEST}"
elif [ ${MODE} = "SERVICE" ]
then
	pkill "$TESTPROCNAME"
	pkill "$PROCNAME"

	timeout -s 2 ${TIMEOUT} ${BINDER} --name="${PROCNAME}" \
				--port=${PORTSERVICE} \
				--workdir="${SERVICEPACKAGEDIR}" \
				--ldpaths=. \
				$(echo -e "${SOCKETSERVER}") \
				-vvv \
				&> "${LOGFILESERVICE}" &
	B_PID=$(pidof ${PROCNAME})
	sleep 0.3

	timeout -s 9 ${TIMEOUT} ${BINDER} --name="${TESTPROCNAME}" \
				--port="${PORT}" \
				--no-httpd \
				--tracereq=common \
				--token=${TOKEN} \
				--workdir="${TESTPACKAGEDIR}" \
				--binding="${AFBTEST}" \
				$(echo -e "${SOCKETCLIENT}") \
				$(echo -e "${testVerbCalls}") \
				--call="${TESTAPINAME}/exit:{}" \
				-vvv \
				&> "${LOGFILETEST}"

	kill -2 ${B_PID}
	tail --pid=${B_PID} -f /dev/null
else
	echo "Error: No mode selected. Choose between SOLO or SERVICE"
	usage
	cleanNexit 3
fi

if [ "${COVERAGE}" = "TRUE" ]
then
    echo ""
    echo "INFO : Deploying coverage reports in $(readlink -f ${COVERAGE_PATH})"

    mkdir -p "${COVERAGE_PATH}"
    cd "${COVERAGE_PATH}"
    rm -rf ./*

    LCOV_VERSION=$(lcov --version | awk '{print $4}' | tr -d '.')

    if [ $LCOV_VERSION -eq 10 ]
    then
            lcov --directory .. \
                --capture \
                --exclude "/usr/include/*" \
                --exclude "/opt/*" \
                --exclude "*/libs/*" \
                --exclude "*/test/*" \
                --exclude "*/tests/*" \
                --exclude "*/plugins/*" \
                --exclude="*/afb-helpers/*" \
                --exclude="*/ctl-utilities/*" \
                --exclude "*/app-afb-helpers-submodule/*" \
                --exclude "*/app-controller-submodule/*" \
                --output-file coverage.info
    else
            lcov --directory .. \
                --capture \
                --output-file full_coverage.info
            lcov --remove full_coverage.info \
                        '/usr/include/*' \
                        '/opt/*' \
                        '*/libs/*' \
                        '*/test/*' \
                        '*/tests/*' \
                        '*/plugins/*' \
                        '*/afb-helpers/*' \
                        '*/ctl-utilities/*' \
                        '*/app-afb-helpers-submodule/*' \
                        '*/app-controller-submodule/*' \
                --output-file coverage.info
    fi

    genhtml coverage.info

    cd ..
    tar czf coverage.tar.gz "${COVERAGE_PATH}"
    echo ""
fi

cleanNexit $?
