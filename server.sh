#!/bin/bash

CURRENT_DIR="$(pwd)"
BASENAME="$(basename ${CURRENT_DIR})"
SYSTEM_DIR="${CURRENT_DIR}/../System"
UCC="${SYSTEM_DIR}/ucc.exe"

if [[ -f ${BASENAME}.inc ]]; then
    VERSION=$(sed 's/^#define __VERSION__ \(.*\)$/\1/p;d' ${BASENAME}.inc)
else
    VERSION="UNKNOWN_VERSION"
fi
if [[ -d .git ]]; then
    BUILD_INFO=$(git branch | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')-$(git rev-parse --short HEAD)$([ -z "$(git status --porcelain 2>/dev/null | tail -n1)" ] || echo '-dirty')
    VERSION_STRING="${VERSION}-${BUILD_INFO}"
else
    BUILD_INFO=""
    VERSION_STRING="${VERSION}"
fi

SERVER_CMDLINE="DM-Rankin?Game=SkaarjPack.Invasion?AdminName=Admin?AdminPassword=W1ldFl0w3r5?Mutator=TURRPG2.MutTURRPG"
SERVER_PORT="7777"
SERVER_NAME="(Testing) ${BASENAME}-${VERSION_STRING}"

echo -n "Obtaining external IP address... "
EXT_IP=$(curl -s http://ipecho.net/plain)
echo -n "${EXT_IP}"
echo
echo "Setting external IP as redirect server..."
sed -i "s/^\(RedirectToURL=\).*$/\1http:\/\/${EXT_IP}:8000\//" server.ini
echo "Enabling compression for redirect..."
sed -i "s/^\(UseCompression=\).*$/\1True/" server.ini
echo -n "Starting redirect server... "
python3 simple_redirect.py -d .. -c -n &
HTTPD_PID=$(echo $!)
echo -n "(PID: ${HTTPD_PID})"
echo
echo "Setting server name to ${SERVER_NAME}..."
sed -i "s/^\(ServerName=\).*$/\1${SERVER_NAME}/" server.ini
echo "Server starting... Send keyboard interrupt to stop server."
wine ${UCC} server "${SERVER_CMDLINE}" port="${SERVER_PORT}" ini=../${BASENAME}/server.ini log=../${BASENAME}/server.log 2>/dev/null
echo "Server stopped."
echo "Backing up server log."
if [[ ! -d Logs ]]; then
    mkdir Logs
fi
cp -v server.log Logs/server-$(date +%Y%m%d-%H%M%S).log
kill ${HTTPD_PID}
echo "Redirect server stopped."
