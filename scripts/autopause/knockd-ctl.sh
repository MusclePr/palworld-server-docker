#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

interfaces="${AUTO_PAUSE_KNOCK_INTERFACES:-auto}"
basedir="/home/steam/server/autopause"
config="${basedir}/knockd.cfg"

declare -a resolvedInterfaces=()

appendInterface() {
    local iface="${1}" existing

    [ -z "${iface}" ] && return
    [ ! -d "/sys/class/net/${iface}" ] && return

    for existing in "${resolvedInterfaces[@]}"; do
        [ "${existing}" = "${iface}" ] && return
    done

    resolvedInterfaces+=("${iface}")
}

resolveAutoInterfaces() {
    local iface destination flags type netPath

    if [ -r "/proc/net/route" ]; then
        while read -r iface destination _gateway flags _rest; do
            if [ "${destination}" = "00000000" ] && [ -n "${flags}" ]; then
                appendInterface "${iface}"
            fi
        done < "/proc/net/route"
    fi

    for netPath in /sys/class/net/*; do
        if [ ! -r "${netPath}/type" ]; then
            continue
        fi
        type=$(cat "${netPath}/type")
        if [ "${type}" = "772" ]; then
            appendInterface "$(basename "${netPath}")"
        fi
    done
}

resolveInterfaces() {
    local iface

    resolvedInterfaces=()
    if [ "${interfaces}" = "auto" ]; then
        resolveAutoInterfaces
        return
    fi

    for iface in ${interfaces}; do
        appendInterface "${iface}"
    done
}

case "${1}" in
"start")
    if [ ! -f "${config}" ]; then
        cat - << EOF > "${config}"
[options]
 logfile = /dev/null
[resume-by-player]
 sequence = ${PORT:-8211}:udp
 seq_cooldown = 5
 command = autopause resume "LOGIN from %IP%"
[resume-by-rcon]
 sequence = ${RCON_PORT:-25575}
 seq_timeout = 1
 command = autopause resume "RCON from %IP%"
 tcpflags = syn
[resume-by-rest]
 sequence = ${REST_API_PORT:-8212}
 seq_timeout = 1
 command = autopause resume "REST_API from %IP%"
 tcpflags = syn
EOF
    fi
    resolveInterfaces
    if [ "${#resolvedInterfaces[@]}" -eq 0 ]; then
        LogWarn "AUTO_PAUSE_KNOCK_INTERFACES=${interfaces} did not resolve any usable interfaces."
        exit 1
    fi
    knockdArgs=(-d -c "${config}")
    if isTrue "${AUTO_PAUSE_DEBUG:-false}"; then
        LogInfo "AUTO_PAUSE_KNOCK_INTERFACES=\"${interfaces}\" resolved to: \"${resolvedInterfaces[*]}\""
        knockdArgs+=(-D)
    fi
    # Detects knocks coming from interfaces.
    for iface in "${resolvedInterfaces[@]}"; do
        knockd "${knockdArgs[@]}" -i "${iface}" -p "${basedir}/.knockd-${iface}.pid"
    done
    ;;
"stop")
    for pidFile in "${basedir}"/.knockd-*.pid; do
        if [ -f "${pidFile}" ]; then
            kill -KILL "$(cat "${pidFile}")"
            rm -f "${pidFile}"
        fi
    done
    ;;
*)
    echo "Usage: $(basename "${0}") <command>"
    echo "command:"
    echo "    start ... launch knockd"
    echo "    stop  ... kill knockd"
esac
