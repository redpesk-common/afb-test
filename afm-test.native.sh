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
#	 http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################


function usage() {
	cat >&2 << EOF

Usage: $0 <binding-wgt-rootdir> <test-wgt-rootdir> [-a|--allinone] [-p|--clean-previous] [-t|--timeout <X>] [-l|--lavaoutput] [-c|--coverage] [-o|--coverage-dir <X>] [-e|--exclude <X>] [-i|--include <X>] [-h|--help] [-d|--debug]
binding-wgt-rootdir: path to the test wgt file
test-wgt-rootdir: path to the test folder file
-a|--allinone: All In One (1 binder for the test) for some specific debug, use carefully.
-p|--clean-previous: Clean previous test and coverage results and exit.
-t|--timeout: timeout in second. (Default 300 seconds)
-l|--lavaoutput: Flags indicating the binding to add Lava special test markers.
-c|--coverage: Deploy coverage reports once the tests are completed.
-o|--coverage-dir: Choose coverage directory
-e|--exclude: exclude a test, can be use more than one time. (disabled if only one test verb found)
-i|--include: only include a test, can be use more than one time. (disabled if only one test verb found)
-d|--debug: debug mode.
-h|--help: Print help
EOF
}

BINDER="$(command -v afb-daemon)"
AFBTEST="$(pkg-config --variable libdir afb-test)/aft.so"
PORT=1234
PORTSERVICE=$((PORT+1))
TOKEN=
MODE="SERVICE"
TIMEOUT=300
DBG_MODE="FALSE"
CUR_DIR=$(pwd)

INCLUDE_TEST=()
EXCLUDE_TEST=()
CUR_TEST=()
export INCLUDE_TEST
export EXCLUDE_TEST
export CUR_TEST

COVERAGE="FALSE"
COVERAGE_PATH=$(readlink -f "coverage")
CLEAN_PRV="FALSE"
HAVE_PRV_COV=FALSE
LOGFILESERVICE="test-service.log"
LOGFILETEST="test.log"
NOTIFY_SOCKET="/tmp/socket_notify.socket"
export NOTIFY_SOCKET

clean_previous_test() {
	echo "Cleaning previous test reports ..."
	find "${TESTPACKAGEDIR}" -maxdepth 1 -name '*.tap' -exec rm -v {} \;
	find . -name "*.gcda" -exec rm -v {} \;
	rm -frv "${COVERAGE_PATH}"
	find . -name "coverage.tar.gz" -exec rm -v {} \;
}

printResultCoverage() {
	if [ -f "${COVERAGE_PATH}/coverage.info" ]; then
	{
		echo
		echo "----------- Coverage report result ------------"
		echo "Deploying coverage reports in : $(readlink -f "${COVERAGE_PATH}")"
		if [ "${HAVE_PRV_COV}" == "TRUE" ];then
			echo "WARNING: A previous coverage report has been found for this project, it will be overwritten."
		fi
		echo "-----------------------------------------------"
		cd "${COVERAGE_PATH}" || exit
		genhtml "${COVERAGE_PATH}"/coverage.info
		echo "-----------------------------------------------"

		cd "${CUR_DIR}" || exit 1
		COV_DIR="$(dirname "${COVERAGE_PATH}")"
		COV_BSN="$(basename "${COVERAGE_PATH}")"

		tar "${TAR_OPT}" --create --gzip --file coverage.tar.gz --directory "${COV_DIR}" "${COV_BSN}"
	}
	else
	{
		echo "-----------------------------------------------"
		echo "--- Can't find any Coverage report for this project ---"
		echo "-----------------------------------------------"
	}
	fi
}

printResultTest() {
	echo "---------------- Test result ------------------"
	PREV_TEST=()
	NB_TEST=${#CUR_TEST[@]}
	#Only print the current tap or all the tap?
	RES_FILE_LIST=$(find "${TESTPACKAGEDIR}" -maxdepth 1 -name '*.tap')

	for RES_FILE in $RES_FILE_LIST; do
		IS_CUR="FALSE"
		RES_TEST="$(basename "${RES_FILE}"| cut  -d'.' -f1)"

		for (( id_t=0; id_t<NB_TEST; id_t++ )) do
			if [[ "${RES_TEST}" == "${CUR_TEST[id_t]}" ]];then
				IS_CUR="TRUE"
				break
			fi
		done

		if [ "${IS_CUR}" == "TRUE" ];then
			#Print the file path of the test
			echo "Test result from: $RES_FILE"
			if [ "${DBG_MODE}" = "TRUE" ];then
				cat "$RES_FILE"
			else
			#Only print the result line
				grep "# Ran" "$RES_FILE"
				echo ""
			fi
		else
			PREV_TEST+=("${RES_FILE}")
		fi
	done

	if (( ${#PREV_TEST[@]} )); then
		echo "Previous test reports have been found for this project !"
		for RES_FILE in "${PREV_TEST[@]}"; do
			echo ""
			echo "Test result from: $RES_FILE"
			if [ "${DBG_MODE}" = "TRUE" ];then
				cat "$RES_FILE"
			else
			#Only print the result line
				grep "# Ran" "$RES_FILE"
			fi
		done
	fi
	echo "-----------------------------------------------"

	#Is it useful?
	find "${TESTPACKAGEDIR}" -maxdepth 1 -name '*.txt' -exec cat {} \;

	#Is it useful?
	find "${TESTPACKAGEDIR}" -maxdepth 1 -name '*.xml' -a ! -name 'config.xml' -exec cat {} \;
	echo "To see which test passed or not, see test files."
}

printResult() {
	if [ "$1" -ne 0 ]
	then
		#Where 124 and 137 come from? timeout?
		if [[ $1 -eq 124 ]] || [[ $1 -eq 137 ]]
		then
			echo -e "Error: Test timed out. Try to use '-t' options to increase the timeout.\nError: Exit Code: $1"
			echo -e "Error: Current timeout value is: $TIMEOUT"
			TIMEOUT
		else
			echo -e "Error: Test launch failed.\nError: Exit Code: $1"
		fi
	else
		printResultTest
		if [ "${COVERAGE}" = "TRUE" ]; then
			printResultCoverage
		fi
	fi
}

trap "cleanNexit 1" SIGHUP SIGINT SIGABRT SIGTERM
cleanNexit() {
	cd "${CUR_DIR}" || exit 1
	#Remove all tmp files
	for A in ${APIs};do
		rm -f /tmp/"${A}" 2> /dev/null
	done

	rm -f "${NOTIFY_SOCKET}"
	rm -f /tmp/waiting_notify.py

	trap '' EXIT SIGHUP SIGINT SIGABRT SIGTERM
	printResult "$1"
	exit "$1"
}

gen_test_env_var(){
	ENV_API="${API//[^a-zA-Z0-9_]/_}"
	declare AFT_"${ENV_API}"_CONFIG_PATH="${SERVICEPACKAGEDIR}"
	declare AFT_"${ENV_API//[^a-zA-Z0-9_]/_}"_PLUGIN_PATH="${SERVICEPACKAGEDIR}"
	export AFT_"${ENV_API}"_CONFIG_PATH
	export AFT_"${ENV_API}"_PLUGIN_PATH

	export AFT_CONFIG_PATH="${TESTPACKAGEDIR}"
	export AFT_PLUGIN_PATH="${TESTPACKAGEDIR}"
	export AFT_CONFIG_PATH
	export AFT_PLUGIN_PATH
}

gen_test_var(){
	TESTCFGFILE=$(find "${TESTPACKAGEDIR}" -name "aft-*.json" -print | head -n1)
	TESTAPINAME=$(grep '\"api\"' "${TESTCFGFILE}" | cut -d'"' -f4)

	if [ ! -f "${TESTPACKAGEDIR}/config.xml" ]; then
		echo "Error: can't find config.xml file for this project. Please call 'make widget'"
		cleanNexit 5
	fi
	TESTPROCNAME="afbd-$(grep -Eo 'id=".*" ' "${TESTPACKAGEDIR}/config.xml" | cut -d'=' -f2 | tr -d '" '| tr '[:upper:]' '[:lower:]')"
	PROCNAME="afbd-$(grep -Eo 'id=".*" ' "${SERVICEPACKAGEDIR}/config.xml" | cut -d'=' -f2 | tr -d '" '| tr '[:upper:]' '[:lower:]')"

	export TESTCFGFILE
	export TESTAPINAME
	export TESTPROCNAME
	export PROCNAME
}

run_all_in_one_test() {
	timeout -s 9 "${TIMEOUT}" \
		"${BINDER}" --name="${TESTPROCNAME}" \
			--port="${PORT}" \
			--roothttp=. \
			--tracereq=common \
			--token="${TOKEN}" \
			--workdir="${TESTPACKAGEDIR}" \
			--ldpaths="${SERVICEPACKAGEDIR}" \
			--binding="${AFBTEST}" \
			"${TEST_VERB_CALLS[@]}" \
			--call="${TESTAPINAME}/exit:{}" \
			-vvv \
			&> "${LOGFILETEST}"
}

run_test() {
	pkill "${TESTPROCNAME}"
	pkill "$PROCNAME"
	#Create a server socket waiting for notification
	cat << EOF > /tmp/waiting_notify.py
#!/usr/bin/python3
import socket
with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as server:
	server.bind("${NOTIFY_SOCKET}")
	server.settimeout(${TIMEOUT})
	server.recv(1024)
EOF
	chmod a+x /tmp/waiting_notify.py
	rm -f "${NOTIFY_SOCKET}"
	/tmp/waiting_notify.py&
	PID_WTN="$!"
	#Waiting socket creation.
	while [ ! -S "${NOTIFY_SOCKET}" ]; do sleep 0.1; done

	timeout -s 9 "${TIMEOUT}" \
		"${BINDER}"\
			--name="${PROCNAME}" \
			--port=${PORTSERVICE} \
			--workdir="${SERVICEPACKAGEDIR}" \
			--ldpaths=. \
			"${SOCKETSERVER[@]}" \
			-vvv \
			&> "${LOGFILESERVICE}" &

	#Wait the sd_notify notification
	tail --pid="${PID_WTN}" -f /dev/null
	B_PID=$(pidof "${PROCNAME}")
	rm -f "${NOTIFY_SOCKET}"
	rm -f /tmp/waiting_notify.py

	#Do not start the Binder before to be absolutly sure the server is up.
	timeout -s 9 "${TIMEOUT}" \
		"${BINDER}" \
			--name="${TESTPROCNAME}" \
			--port="${PORT}" \
			--no-httpd \
			--tracereq=common \
			--token="${TOKEN}" \
			--workdir="${TESTPACKAGEDIR}" \
			--binding="${AFBTEST}" \
			"${SOCKETCLIENT[@]}" \
			"${TEST_VERB_CALLS[@]}" \
			--call="${TESTAPINAME}/exit:{}" \
			-vvv \
			&> "${LOGFILETEST}"

	kill -2 "${B_PID}"
	tail --pid="${B_PID}" -f /dev/null
}

gen_test_parameter() {
	APIs=$(sed '/feature.*provided-api/,/feature/!d' "${SERVICEPACKAGEDIR}/config.xml" | grep -v feature| sed -r -e 's:.*"(.*)" v.*:\1:')
	API=$(echo "${APIs}" | cut -d" " -f1)

	if [ -z "$API" ] && [ "$MODE" = "SERVICE" ]; then
		echo "Error: can't find config.xml file for this project. Please call 'make widget'"
		cleanNexit 2
	fi

	SOCKETCLIENT=();
	SOCKETSERVER=();

	for A in ${APIs};do
		SOCKETCLIENT+=("--ws-client=unix:/tmp/${A}");
		SOCKETSERVER+=("--ws-server=unix:/tmp/${A}");
	done

	testVerb=()

	if [[ $(jq -r '.testVerb|type' "${TESTCFGFILE}") == "array" ]];	then
			testVerbLength=$(jq '.testVerb|length' "${TESTCFGFILE}")
			for (( idx=0; idx<testVerbLength; idx++ )) do
					testVerb[$idx]=$(jq -r ".testVerb[$idx].uid" "${TESTCFGFILE}")
			done
	else
			testVerb[0]=$(jq -r ".testVerb.uid" "${TESTCFGFILE}")
	fi

	testVerbLength=${#testVerb[@]}
	TEST_VERB_CALLS=()

	if [ "${LAVAOUTPUT}" ];then
			LAVA_OPT="\"lavaOutput\":true"
	fi

	NB_INC=${#INCLUDE_TEST[@]}
	NB_EXC=${#EXCLUDE_TEST[@]}

	if [ "$testVerbLength" -gt 1 ]; then
		for (( idx=0; idx<testVerbLength; idx++ )) do
			TV="${testVerb[idx]}"
			IS_INC="FALSE"
			if [ "$NB_INC" -gt 0 ];then
				IS_EXC="TRUE"
			else
				IS_EXC="FALSE"
			fi

			for (( id_i=0; id_i<NB_INC; id_i++ )) do
				if [[ "${TV}" == "${INCLUDE_TEST[id_i]}" ]];then
					IS_INC="TRUE"
					break
				fi
			done

			for (( id_e=0; id_e<NB_EXC; id_e++ )) do
				if [[ "${TV}" = "${EXCLUDE_TEST[id_e]}" ]];then
					IS_EXC="TRUE"
					break
				fi
			done

			if	[ "${IS_INC}" == "TRUE" ] || [ "${IS_EXC}" == "FALSE" ]; then
				TEST_VERB_CALLS+=("--call=${TESTAPINAME}/${TV}:{$LAVA_OPT}")
				TAB_FILE=$(jq -r ".testVerb[$idx].args.files" "${TESTCFGFILE}" | grep lua| cut  -d'.' -f1 | cut -d'"' -f2)
				for TF in $TAB_FILE; do
					CUR_TEST+=("${TF}")
				done
			fi
		done
	else
		TV="${testVerb}"
		TEST_VERB_CALLS+=("--call=${TESTAPINAME}/${TV}:{$LAVA_OPT}")
		TAB_FILE=$(jq -r ".testVerb.args.files" "${TESTCFGFILE}" | grep lua| cut  -d'.' -f1 | cut -d'"' -f2)
		for TF in $TAB_FILE; do
			CUR_TEST+=("${TF}")
		done
	fi

	export TEST_VERB_CALLS
	export SOCKETCLIENT
	export SOCKETSERVER
}

do_test() {
	gen_test_env_var
	gen_test_var
	gen_test_parameter

	pkill "${TESTPROCNAME}"
	if [ "${MODE}" = "SOLO" ];then
		run_all_in_one_test
	elif [ "${MODE}" = "SERVICE" ];	then
		run_test
	else
		echo "Error: No mode selected. Choose between SOLO or SERVICE"
		usage
		cleanNexit 3
	fi
}

do_coverage() {
	if [ "${DBG_MODE}" = "TRUE" ];then
		echo ""
		echo "INFO : Deploying coverage reports in $(readlink -f "${COVERAGE_PATH}")"
	fi

	GCDA_PATH=$(find . -name "*.gcda")

	if [ -z "${GCDA_PATH}" ]; then
		echo "WARNING: No coverage file found, aborting."
		return;
	fi

	mkdir -p "${COVERAGE_PATH}"
	if [ ! -d "${COVERAGE_PATH}" ]; then
		echo "ERROR: ${COVERAGE_PATH} is not a valid directory"
		cleanNexit 1
	fi

	cd "${COVERAGE_PATH}" || exit
	rm -rf ./*

	LCOV_VERSION=$(lcov --version | awk '{print $4}' | tr -d '.')

	#Who use lcov in version 10?
	if [ "${LCOV_VERSION}" -eq 10 ]
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
				--output-file coverage.info \
				> lcov.log
	else
			lcov --directory .. \
				--capture \
				--output-file full_coverage.info \
				> lcov.log

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
						--output-file coverage.info \
						>> lcov.log
	fi

	if [ "${DBG_MODE}" = "TRUE" ];then
		cat lcov.log
		TAR_OPT="--verbose"
	fi
}

#--- MAIN ---
while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-h|--help)
			shift # past argument
			usage
			exit 0
		;;
		-p|--clean-previous)
			CLEAN_PRV="TRUE"
			shift # past argument
		;;
		-e|--exclude)
			EXCLUDE_TEST+=("$2")
			shift # past argument
			shift # past value
		;;
		-i|--include)
			INCLUDE_TEST+=("$2")
			shift # past argument
			shift # past value
		;;
		-d|--debug)
			DBG_MODE="TRUE"
			shift # past argument
		;;
		-l|--lavaoutput)
			LAVAOUTPUT="TRUE"
			shift # past argument
		;;
		-a|--allinone)
			MODE="SOLO"
			shift # past argument
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
		-o|--coverage-dir)
			COVERAGE_PATH="$(readlink -f "$2")"
			shift # past argument
			shift # past value
			;;
		*)
			if [ -z "${SERVICEPACKAGEDIR}" ]; then
				SERVICEPACKAGEDIR="$(readlink -f "$1")"
			elif [ -z "${TESTPACKAGEDIR}" ]; then
				TESTPACKAGEDIR="$(readlink -f "$1")"
			else
				usage
				exit 1
			fi
			shift # past argument
		;;
	esac
done

if [ -f "${COVERAGE_PATH}/coverage.info" ]; then
	HAVE_PRV_COV="TRUE"
fi

if [ "${DBG_MODE}" = "TRUE" ];then
	set -x
fi

#TODO : Maybe add a default value
if [ -z "$SERVICEPACKAGEDIR" ] || [ -z "$TESTPACKAGEDIR" ]; then
	echo "Error: you did not specify either the binding folder location or test widget folder location."
	usage
	cleanNexit 1
fi

if [ "${CLEAN_PRV}" == "TRUE" ]; then
	clean_previous_test
	exit 0
fi

do_test

if [ "${COVERAGE}" = "TRUE" ];then
	do_coverage
fi

cleanNexit $?
