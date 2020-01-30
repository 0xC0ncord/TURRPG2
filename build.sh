#!/bin/bash

CURRENT_DIR="$(pwd)"
BASENAME="$(basename ${CURRENT_DIR})"
SYSTEM_DIR="${CURRENT_DIR}/../System"
UCC="${SYSTEM_DIR}/ucc.exe"

if [[ -d .git ]]; then
    BUILD_INFO=$(git rev-parse --short HEAD)$([ -z "$(git diff --shortstat 2>/dev/null | tail -n1)" ] || echo '-dirty')
else
    BUILD_INFO=""
fi
BUILD_DATE="$(date +"%a %d %b %Y %H:%M:%S %Z")"

NO_RESTORE=0
NO_PREPROCESS=0
RELEASE_BUILD=0

PREPROCESSED=0
EXIT_STATUS=0

restore () {
    if [[ NO_RESTORE -eq 0 ]]; then
        rm -rf ${CURRENT_DIR}/Classes
        mv -vf ${CURRENT_DIR}/.Classes ${CURRENT_DIR}/Classes
    fi
}

for ARG in "$@"; do
    case $ARG in
        "-h" | "--help")
            echo "Usage: build.sh [options]"
            echo
            echo " -n, --no-restore      : don't restore original Classes source tree when finishing"
            echo " -s, --skip-preprocess : skip the preprocessing phase entirely"
            echo " -r, --release         : compile with the __DEBUG__ macro undefined (for release builds)"
            exit 0
            ;;
        "-n" | "--no-restore")
            NO_RESTORE=1
            ;;
        "-s" | "--skip-preprocess")
            NO_PREPROCESS=1
            ;;
        "-r" | "--release")
            RELEASE_BUILD=1
            ;;
        *)
            echo "Unrecognized option \'$ARG\'"
            exit 1
            ;;
    esac
done

if [[ -n "$(lsof +D ${CURRENT_DIR}/Classes)" ]]; then echo 'Classes directory tree open in some program(s). Please close before continuing.' && exit 1; fi
if [[ ${RELEASE_BUILD} -eq 0 ]]; then
    echo -e "\e[92mBuild: DEBUG\e[0m"
else
    echo -e "\e[92mBuild: RELEASE\e[0m"
fi
echo Preparing...
if [[ -d ${CURRENT_DIR}/.Classes  ]]; then
    echo -e "\e[91m(!) Original Classes source tree appears to have not been restored.\e[0m"
    echo -e "\e[91m    If you think this is in error, run 'make clean' before invoking the build script again.\e[0m"
    echo -e "\e[93mContinuing in 5 seconds...\e[0m"
    sleep 5
    SHA1SUM="$(find ${CURRENT_DIR}/.Classes -type f -iname '*.uc' -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{print $1}')"
else
    SHA1SUM="$(find ${CURRENT_DIR}/Classes -type f -iname '*.uc' -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{print $1}')"
fi
SHA1SUM_OLD="$(cat ${CURRENT_DIR}/Classes.sha1sum 2>/dev/null)"
if [[ -f ${CURRENT_DIR}/Classes.sha1sum && "${SHA1SUM_OLD}" = "${SHA1SUM}" ]]; then echo 'Source directory unchanged since last build. Nothing to do. Exiting.' && exit 1; fi
if [[ ${NO_PREPROCESS} -eq 0 ]]; then
    echo Preprocessing...
    if [[ -f ${CURRENT_DIR}/Classes/.preprocessed ]]; then
        echo -e "\e[91m(!) Classes source tree appears to have already been preprocessed. Skipping...\e[0m"
        echo -e "\e[91m    If you think this is in error, run 'make clean' before invoking the build script again.\e[0m"
    else
        cp -r ${CURRENT_DIR}/Classes ${CURRENT_DIR}/.Classes
        if [[ ${RELEASE_BUILD} -eq 0 ]]; then
            CMDLINE="-D__DEBUG__"
        fi
        if [[ -f ${CURRENT_DIR}/${BASENAME}.inc ]]; then
            for FILE in ${CURRENT_DIR}/.Classes/*.uc; do
                gpp -C "${CMDLINE}" -D__BUILDINFO__="${BUILD_INFO}" -D__BUILDDATE__="${BUILD_DATE}" --include ${CURRENT_DIR}/${BASENAME}.inc ${FILE} -o ${CURRENT_DIR}/Classes/$(basename ${FILE})
            done
        else
            for FILE in ${CURRENT_DIR}/.Classes/*.uc; do
                gpp -C "${CMDLINE}" -D__BUILDINFO__="${BUILD_INFO}" -D__BUILDDATE__="${BUILD_DATE}" ${FILE} -o ${CURRENT_DIR}/Classes/$(basename ${FILE})
            done
        fi
        touch ${CURRENT_DIR}/Classes/.preprocessed
    fi
fi
echo Compiling...
if [[ -f ${SYSTEM_DIR}/${BASENAME}.u ]]; then mv -vf ${SYSTEM_DIR}/${BASENAME}.u ${SYSTEM_DIR}/.${BASENAME}.u.bak; fi
{
    wine ${UCC} MakeCommandletUtils.EditPackagesCommandlet 1 ${BASENAME} 2>/dev/null &&
    wine ${UCC} make ini=..\\${BASENAME}\\make.ini 2>/dev/null && echo ${SHA1SUM} > ${CURRENT_DIR}/Classes.sha1sum &&
    wine ${UCC} MakeCommandletUtils.EditPackagesCommandlet 0 ${BASENAME} 2>/dev/null
} || {
    mv -vf ${SYSTEM_DIR}/.${BASENAME}.u.bak ${SYSTEM_DIR}/${BASENAME}.u
    EXIT_STATUS=1
}
restore
exit $EXIT_STATUS
