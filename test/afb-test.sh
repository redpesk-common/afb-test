#!/bin/sh

trap "cleanup 1" SIGINT SIGTERM SIGABRT SIGHUP
trap "cleanup 0" EXIT

cleanup() {
	trap '' SIGINT SIGTERM SIGABRT SIGHUP EXIT
	kill $AFTESTPID > /dev/null 2>&1
	rm -f $AFTESTSOCKET
	pkill $PROCNAME
	exit $1
}

BINDER=$(command -v afb-daemon)
PROCNAME="aft-aftest"
PORT=1234
TOKEN=
AFTESTSOCKET=/tmp/afTest

[ "$1" ] && BUILDDIR="$1" || exit 1

pkill $PROCNAME

${BINDER} --name=afbd-aftest \
--workdir="${BUILDDIR}/package" \
--binding=lib/aft.so \
--ws-server=unix:${AFTESTSOCKET} > /dev/null 2>&1 &
AFTESTPID=$!

sleep 0.3

${BINDER} --name="${PROCNAME}" \
--port="${PORT}" \
--no-httpd \
--tracereq=common \
--token=${TOKEN} \
--workdir="${BUILDDIR}/package-test" \
--binding="${BUILDDIR}/package/lib/aft.so" \
--ws-client=unix:${AFTESTSOCKET} \
--call="aft-aftest/launch_all_tests:{}" \
--call="aft-aftest/exit:{}"

find "${BUILDDIR}" -name test_results.log -exec cat {} \;
