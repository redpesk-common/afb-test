#!/bin/sh -x

trap cleanup SIGINT SIGTERM SIGABRT SIGHUP

cleanup() {
	rm -f $LOGPIPE
	pkill $PROCNAME
	exit 1
}

BINDER=$(command -v afb-daemon)
AFBTEST="$(pkg-config --variable libdir afb-test)/aft.so"
PROCNAME="aft-aftest"
PORT=1234
TOKEN=
LOGPIPE="test.pipe"

[ "$1" ] && BUILDDIR="$1" || exit 1

[ ! -p $LOGPIPE ] && mkfifo $LOGPIPE

pkill $PROCNAME

${BINDER} --name="${PROCNAME}" \
--port="${PORT}" \
--no-httpd \
--tracereq=common \
--token=${TOKEN} \
--workdir="${BUILDDIR}/package-test" \
--binding="$AFBTEST" \
-vvv \
--call="afTest/launch_all_tests:{}" \
--call="afTest/exit:{}" > ${LOGPIPE} 2>&1 &

while read -r line
do
	[ "$(echo "${line}" | grep 'NOTICE: Browser URL=')" ] && break
done < ${LOGPIPE}

rm -f ${LOGPIPE}
