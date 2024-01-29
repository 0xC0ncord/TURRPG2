#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)"
PACKAGE="$(basename "${BASE_DIR}")"

usage() {
    cat <<_EOF_
Usage: $(basename "${BASH_SOURCE[0]}") [-h|--help] [-v|--verbose] [-n|--no-restore] [-s|--skip-preprocess] [-r|--release]

Build the package and all.

Available options:
    -h, --help              Print this message
    -v, --verbose           Show extra output
    -n, --no-restore        Don't restore the original Classes source tree when finishing
    -s, --skip-preprocess   Skip the preprocessing phase entirely
    -r, --release           Compile with the __DEBUG__ macro undefined (for release builds)
_EOF_
    exit 0
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

msg() {
    echo -e "${@-}" >&2
}

die() {
    echo -e "${@-}" >&2
    exit 1
}

parse_args() {
    NO_RESTORE=0
    NO_PREPROCESS=0
    RELEASE_BUILD=0

    while :; do
        case "${1-}" in
            "-h"|"--help")
                usage
                ;;
            "-v"|"--verbose")
                set -x
                ;;
            "-n"|"--no-restore")
                NO_RESTORE=1
                ;;
            "-s"|"--skip-preprocess")
                NO_PREPROCESS=1
                ;;
            "-r"|"--release")
                RELEASE_BUILD=1
                ;;
            -?*)
                die "Unknown option: ${1}"
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    return 0
}

setup() {
    msg "${GREEN}>>> ${NOFORMAT}Setting up the build environment..."

    SYSTEM_DIR="${BASE_DIR}/../System"
    local ucc="${SYSTEM_DIR}/UCC.exe"

    if [[ "$(uname -r)" == *"WSL"* ]]; then
        COMPILE="${ucc}"
    else
        COMPILE="wine ${ucc}"
    fi

    if [[ -f "${PACKAGE}.inc" ]]; then
        VERSION="$(sed 's/^#define __VERSION__ \(.*\)$/\1/p;d' "${PACKAGE}".inc)"
    else
        VERSION="UNKNOWN_VERSION"
    fi

    if [[ -d .git ]]; then
        BUILD_INFO="$(git branch | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/;s/\s\+/_/g')-$(git rev-parse --short HEAD)$([ -z "$(git status --porcelain 2>/dev/null | tail -n1)" ] || echo '-dirty')"
        VERSION_STRING="${VERSION}-${BUILD_INFO}"
    else
        BUILD_INFO=
        VERSION_STRING="${VERSION}"
    fi
    BUILD_DATE="$(date +"%a %d %b %Y %H:%M:%S %Z")"
}

banner() {
    if [[ ${RELEASE_BUILD} -eq 0 ]]; then
        local build_type="DEBUG"
    else
        local build_type="RELEASE"
    fi
    msg "${GREEN}===============|==============================${NOFORMAT}"
    msg "${GREEN}       Package | ${NOFORMAT}${PACKAGE}"
    msg "${GREEN}    Build Type | ${NOFORMAT}${build_type}"
    msg "${GREEN}===============|==============================${NOFORMAT}"
    msg "${GREEN}       Version | ${NOFORMAT}${VERSION}"
    msg "${GREEN}    Build Info | ${NOFORMAT}${BUILD_INFO}"
    msg "${GREEN}Version String | ${NOFORMAT}${VERSION_STRING}"
    msg "${GREEN}    Build Date | ${NOFORMAT}${BUILD_DATE}"
    msg "${GREEN}===============|==============================${NOFORMAT}"
}

prepare() {
    msg "${GREEN}>>> ${NOFORMAT}Preparing..."

    if [[ -n "$(lsof +D "${BASE_DIR}"/Classes)" ]]; then
        die "Classes directory tree open in some program(s). Please close before continuing."
    fi

    if [[ -d "${BASE_DIR}"/.Classes  ]]; then
        msg "${RED}(!) Original Classes source tree appears to have not been restored.${NOFORMAT}"
        msg "${RED}    If you think this is in error, run 'make clean' before invoking the build script again.${NOFORMAT}"
        msg "${ORANGE}Continuing in 5 seconds...${NOFORMAT}"
        sleep 5
        HASH="$(find "${BASE_DIR}"/.Classes -type f -iname '*.uc' -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{print $1}')"
    else
        HASH="$(find "${BASE_DIR}"/Classes -type f -iname '*.uc' -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{print $1}')"
    fi

    local old_hash="$(cat "${BASE_DIR}"/Classes.sha1sum 2>/dev/null)"
    if [[ -f "${BASE_DIR}"/Classes.sha1sum && "${old_hash}" == "${HASH}" ]]; then
        die "Source directory unchanged since last build. Nothing to do."
    fi
}

preprocess() {
    [[ ${NO_PREPROCESS} -eq 0 ]] || return

    msg "${GREEN}>>> ${NOFORMAT}Preprocessing..."
    if [[ -f "${BASE_DIR}"/Classes/.preprocessed ]]; then
        msg "${RED}(!) Classes source tree appears to have already been preprocessed. Skipping...${NOFORMAT}"
        msg "${RED}    If you think this is in error, run 'make clean' before invoking the build script again.${NOFORMAT}"
    else
        cp -r "${BASE_DIR}"/Classes "${BASE_DIR}"/.Classes

        local opts=()
        [[ "${RELEASE_BUILD}" -eq 0 ]] && opts+=("-D__DEBUG__")

        local num_inc_lines=0
        if [[ -f "${BASE_DIR}/${PACKAGE}.inc" ]]; then
            # Test number of lines in output include file
            gpp \
                -n -U "" "" "(" "," ")" "(" ")" "#" "" \
                -M "\n#\w" "\n" " " " " "\n" "" "" \
                +cccs "/*" "*/" +cccs "//" "\n" +cccs "\\\n" "" \
                +s "\"" "\"" "\\" +s "'" "'" "\\" \
                ${OPTS[@]} \
                -D__VERSION__="${VERSION}" \
                -D__BUILDINFO__="${BUILD_INFO}" \
                -D__VERSIONSTRING__="${VERSION_STRING}" \
                -D__BUILDDATE__="${BUILD_DATE}" \
                -D__FILE__="${PACKAGE}.inc" \
                -o "${BASE_DIR}/.${PACKAGE}.inc" \
                "${BASE_DIR}/${PACKAGE}.inc"

            num_inc_lines=$(wc -l "${BASE_DIR}/.${PACKAGE}.inc" | cut -d' ' -f1)
            rm "${BASE_DIR}/.${PACKAGE}.inc"
            opts+=("--nostdinc")
            opts+=("--include ${BASE_DIR}/${PACKAGE}.inc")
        fi

        for file in "${BASE_DIR}"/.Classes/*.uc; do
            local dest="${BASE_DIR}/Classes/$(basename "${file}")"
            gpp \
                -n -U "" "" "(" "," ")" "(" ")" "#" "" \
                -M "\n#\w" "\n" " " " " "\n" "" "" \
                +csss "/*" "*/" +csss "//" "\n" +csss "\\\n" "" \
                +s "\"" "\"" "\\" +s "'" "'" "\\" \
                ${opts[@]} \
                -D__VERSION__="${VERSION}" \
                -D__BUILDINFO__="${BUILD_INFO}" \
                -D__VERSIONSTRING__="${VERSION_STRING}" \
                -D__BUILDDATE__="${BUILD_DATE}" \
                -D__FILE__="$(basename "${file}")" \
                -o "${dest}" \
                "${file}"

            # Remove lines occupied by include file if we used one
            if [[ ${num_inc_lines} -ne 0 ]]; then
                tail -n +$((${num_inc_lines} + 1)) "${dest}" >"${dest}.1"
                mv -f "${dest}.1" "${dest}"
            fi
        done
        touch "${BASE_DIR}"/Classes/.preprocessed
    fi
}

compile() {
    msg "${GREEN}>>> ${NOFORMAT}Compiling..."
    [[ -f "${SYSTEM_DIR}/${PACKAGE}.u" ]] && mv -vf "${SYSTEM_DIR}/${PACKAGE}.u" "${SYSTEM_DIR}/.${PACKAGE}.u.bak"

    {
        ${COMPILE} make ini=..\\"${PACKAGE}"\\make.ini 2>/dev/null && echo "${HASH}" >"${BASE_DIR}"/Classes.sha1sum
        return 0
    } || {
        mv -vf "${SYSTEM_DIR}/.${PACKAGE}.u.bak" "${SYSTEM_DIR}/${PACKAGE}.u"
        return 1
    }
}

restore() {
    if [[ ${NO_RESTORE} -eq 0 ]]; then
        rm -rf "${BASE_DIR}"/Classes
        mv -vf "${BASE_DIR}"/.Classes "${BASE_DIR}"/Classes
    fi
}

main() {
    setup_colors
    parse_args

    setup

    banner
    prepare
    preprocess

    local err=0
    compile || err=1
    restore
    exit ${err}
}

main
