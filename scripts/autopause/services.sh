#!/bin/bash
# shellcheck source=scripts/autopause/functions.sh
source "/home/steam/server/autopause/functions.sh"

#-------------------------------
# PalConfig vars
#-------------------------------
SAVE_DIR=""
SERVER_ID=""

#-------------------------------
# AutoPause vars
#-------------------------------
declare -i AP_no_player_sec=0

#-------------------------------
# AutoPause Community vars
#-------------------------------
declare -r APComm_basedir="/home/steam/server/autopause/community"
declare -r APComm_register_file="${APComm_basedir}/register.json"
declare -r APComm_update_file="${APComm_basedir}/update.json"
declare -i APComm_seq=0  # 0:register / 1:update
declare -i APComm_timer=0
APComm_jsonRegister=""
APComm_jsonUpdate=""

#-------------------------------
# PalConfig
#-------------------------------

PalConfig_init() {
    # The PalServer configuration file must already be generated.
    # fetch SERVER_ID from GameUserSettings.ini
    SERVER_ID="$(sed -n -re 's/DedicatedServerName=(.*)/\1/p' "${DATA_DIR}/Pal/Saved/Config/LinuxServer/GameUserSettings.ini")"
    # update SAVE_DIR
    SAVE_DIR="${DATA_DIR}/Pal/Saved/SaveGames/0/${SERVER_ID}"
}

#-------------------------------
# AutoPause Log
#-------------------------------

APLog() {
    isTrue "${AUTO_PAUSE_LOG:-true}" && LogInfo "[AUTO PAUSE] ${1}"
}

APLog_debug() {
    isTrue "${AUTO_PAUSE_DEBUG:-false}" && LogInfo "[AUTO PAUSE DEBUG] ${1}"
}

#-------------------------------
# AutoPause Core
#-------------------------------

AP_startDaemon() {
    knockd-ctl start
    local pid
    pid=$(pidof knockd)
    APLog_debug "Start knockd (PID:${pid})"
}

AP_stopDaemon() {
    local pid
    pid=$(pidof knockd)
    APLog_debug "Stop knockd (PID:${pid})"
    if [ -n "${pid}" ]; then
        knockd-ctl stop
    fi
}

AP_disable() {
    if isTrue "${1:-on}"; then
        if [[ "$(id -u)" -eq 0 ]]; then
            su steam -c "touch ${AP_disable_file}"
        else
            touch "${AP_disable_file}"
        fi
    else
        rm -f "${AP_disable_file}"
    fi
}

# is realy paused
AP_isSleep() {
    test -n "$(pgrep -r T 'PalServer-Linux')"
}

AP_pause() {
    local on="${1:-on}"
    local pid
    pid=$(pidof PalServer-Linux-Shipping)
    if isTrue "${on}"; then
        if AP_isSleep; then
            APLog "[WARNING] Already sleeped..."
            return 0
        fi
        APLog "Paused. (PID:${pid})"
        kill -STOP "${pid}"
        touch "${AP_pause_file}"
    else
        if ! AP_isSleep; then
            APLog "[WARNING] Already wakeuped..."
            return 0
        fi
        APLog "Wakeup!!! (PID:${pid})"
        kill -CONT "${pid}"
        rm -f "${AP_pause_file}"
    fi
    return 0
}

#-------------------------------
# AutoPause Community API
#-------------------------------

# api.palworldgame.com/server Call
APComm_API() {
    local api="${1}"
    local data="${2}"
    local url="https://api.palworldgame.com/${api}"
    local accept="Accept: application/json"
    local agent="X-UnrealEngine-Agent"
    curl -s -L -X POST "${url}" -H "${accept}" -A "${agent}" --json "${data}"
}

APComm_loadJSON() {
    if [ ! -f "${APComm_register_file}" ] || [ ! -f "${APComm_update_file}" ]; then
        APLog "Captured file not found. Perhaps your mitm proxy server is misconfigured, down, or has lost its connection to api.palworldgames.com."
        return 1
    fi
    local -i result=0 delta
    APComm_jsonRegister="$(jq -c < "${APComm_register_file}")"
    result=$?
    APComm_jsonUpdate="$(jq -c < "${APComm_update_file}")"
    ((result=result+$?))
    if [ ${result} -eq 0 ]; then
        # It's not fresh after 120 seconds.
        ((delta=$(date +%s)-$(date +%s -r "${APComm_update_file}")))
        if [ ${delta} -gt 120 ]; then
            APLog_debug "${APComm_update_file} is not fresh."
            return 1
        fi
    fi
    return ${result}
}

APComm_register() {
    local data response
    data=$(echo -n "${APComm_jsonRegister//\"/\"}" | jq ".name|=\"${SERVER_NAME} (paused)\"")
    response=$(APComm_API "server/register" "${data}")
    local -i result=$?
    if [ ${result} -eq 0 ] && [ -n "${response}" ]; then
        id=$(echo -n "${response//\"/\"}" | jq -r '.server_id')
        key=$(echo -n "${response//\"/\"}" | jq -r '.update_key')
        APComm_jsonUpdate=$(echo -n "${APComm_jsonUpdate//\"/\"}" | jq ".server_id|=\"${id}\"" | jq ".update_key|=\"${key}\"")
        return 0
    fi
    APLog "${response}"
    return 1
}

APComm_update() {
    response=$(APComm_API "server/update" "${APComm_jsonUpdate}")
    local -i result=$?
    if [ ${result} -eq 0 ] && [ -n "${response}" ]; then
        local message status
        message=$(echo "${response//\"/\"}" | jq -r '.error_message')
        status=$(echo "${response//\"/\"}" | jq -r '.status')
        if [ "${status}" = "ok" ]; then
            return 0
        elif [ -n "${message}" ]; then
            APLog "${status}: ${message}"
            return 1
        fi
    fi
    APLog "${response}"
    return 1
}

APComm_init() {
    if ! isTrue "${COMMUNITY}"; then return; fi

    if APComm_loadJSON; then
        APComm_seq=1 # keep continue same update data
    else
        APComm_seq=0 # Start over from registration
    fi
    APComm_timer=0
}

APComm_proc() {
    if ! isTrue "${COMMUNITY}"; then return; fi

    local -i now out
    now="$(date +%s)"
    out="$((APComm_timer+30))"
    if [ "${now}" -gt "${out}" ]; then
        APComm_timer="${now}"
        case ${APComm_seq} in
        0)
            if APComm_register && APComm_update; then
                APComm_seq=1
            fi
            ;;
        1)
            if ! APComm_update; then
                APComm_seq=0
            fi
            ;;
        esac
    fi
}

#-------------------------------
# AutoPause Service API
#-------------------------------

AutoPause_init() {
    APLog "Service ... start"
    PalConfig_init
    AP_disable off
    rm -f "${AP_pause_file}"
    rm -f "${AP_request_file}"
    AutoPause_resetTimer
}

AutoPause_resetTimer() {
    AP_no_player_sec=0
}

AutoPause_addTimer() {
    if AP_isForceDisabled; then return; fi
    local -i delta="${1}"
    ((AP_no_player_sec+=delta))
}

AutoPause_checkRequest() {
    local request
    if request=$(AP_pullRequest); then
        local -r paused="${1:-false}"
        case ${request} in
        Resume*)
            if isTrue "${paused}"; then
                APLog "${request}"
                AP_pause off
            else
                APLog "${request} ... already resumed."
            fi
            ;;
        Disable*)
            if isTrue "${paused}"; then
                APLog "${request}"
                AP_pause off
                AP_disable on
            else
                if AP_isForceDisabled; then
                    APLog "${request} ... already disabled."
                else
                    APLog "${request}"
                    AP_disable on
                fi
            fi
            ;;
        Enable*)
            if isTrue "${paused}"; then
                APLog "${request} ... already enabled."
            else
                if ! AP_isForceDisabled; then
                    APLog "${request} ... already enabled."
                else
                    APLog "${request}"
                    AP_disable off
                fi
            fi
            ;;
        *)
            APLog "Unkown request ... '${request}'"
            ;;
        esac
    fi
}

AutoPause_checkTimer() {
    AP_isEnabled && ! AP_isForceDisabled && test "${AP_no_player_sec}" -gt "${AUTO_PAUSE_TIMEOUT_EST}"
}

AutoPause_challengeToPause() {
    local result
    result=$(is_safe_timing "${SAVE_DIR}")
    APLog "Challenge to pause ... ${result}"
    if [ "${result}" = "OK" ]; then
        if AP_pause on; then
            return 0
        fi
    fi
    return 1
}

AutoPause_waitWakeup() {
    AP_startDaemon
    APComm_init
    while true; do
        sleep 0.5
        AutoPause_checkRequest true
        # resumed by "autopause resume" command
        if ! AP_isSleep; then
            break
        fi
        if ! AP_isPaused; then
            APLog "Detected remove of ${AP_pause_file} and will resume it."
            AP_pause off
            break
        fi
        if AP_isForceDisabled; then
            APLog "Detected create of ${AP_disable_file} and will resume it."
            AP_pause off
            break
        fi
        # During PAUSE,
        # it will continue to register and update
        # the community server list as a dummy.
        APComm_proc
    done
    AP_stopDaemon
}

AutoPause_main() {
    AutoPause_checkRequest false
    if AutoPause_checkTimer; then
        # Safely pause the server when it is not writing files.
        if AutoPause_challengeToPause; then
            # paused
            AutoPause_waitWakeup # Block until player logs in or receives REST API or RCON
            # wake up
            AutoPause_resetTimer
        fi
    fi
}

AutoPause_end() {
    AP_disable off
    rm -f "${AP_pause_file}"
    rm -f "${AP_request_file}"
    APLog "Service ... stopped"
}
