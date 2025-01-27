#!/bin/bash
# This file contains functions which can be used in multiple scripts

#-------------------------------
# AutoPause vars
#-------------------------------
declare -r DATA_DIR="${DATA_DIR:-/palworld}"
declare -r AP_pause_file="${DATA_DIR}/.paused"
declare -r AP_request_file="${DATA_DIR}/.autopause-request"
declare -r AP_disable_file="${DATA_DIR}/.autopause-disabled" # for shutdown and reboot

#-------------------------------
# AutoPause Common
#-------------------------------

AP_isEnabled() {
    isTrue "${AUTO_PAUSE_ENABLED}" && PlayerLogging_isEnabled
}

AP_isPaused() {
    test -e "${AP_pause_file}"
}

AP_isForceDisabled() {
    test -e "${AP_disable_file}"
}

AP_pullRequest() {
    local -i size
    if size=$(stat -c %s "${AP_request_file}" 2>/dev/null) && [ "${size}" -gt 0 ]; then
        cat "${AP_request_file}"
        rm -f "${AP_request_file}"
        return 0
    fi
    return 1
}

AP_pushRequest() {
    if [[ "$(id -u)" -eq 0 ]]; then
        su steam -c "echo \"${1}\" > \"${AP_request_file}\""
    else
        echo "${1}" > "${AP_request_file}"
    fi
}

AP_waitPullRequest()
{
    local -i i=0 max="${1:-100}"
    while [[ i -lt max ]]; do
        ((i++))
        if [ ! -f "${AP_request_file}" ]; then
            return 0
        fi
        sleep 0.1
    done
    rm -f "${AP_request_file}"
    APLog_debug "AP_waitPullRequest ... time out."
    return 1
}
