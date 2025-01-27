#!/bin/bash

#-------------------------------
# launch proxy
#-------------------------------
if isTrue "${COMMUNITY}" && isTrue "${AUTO_PAUSE_ENABLED}" && PlayerLogging_isEnabled; then
    LogAction "AUTO PAUSE with Community"

    LogInfo "Launch proxy."
    MITMPROXY_ADDONS_DIR="/home/steam/server/autopause/community/addons"
    if isTrue "${AUTO_PAUSE_DEBUG}"; then
        mitmweb --web-host 0.0.0.0 --set block_global=false --ssl-insecure -s "${MITMPROXY_ADDONS_DIR}/PalIntercept.py"  &
        LogInfo "Web Interface URL: http://localhost:8081/"
    else
        mitmdump --set block_global=false --ssl-insecure -s "${MITMPROXY_ADDONS_DIR}/PalIntercept.py" > /var/log/mitmdump.log &
    fi

    echo -n "Wait until proxy is initialized..."
    while [ ! -f "/home/steam/.mitmproxy/mitmproxy-ca-cert.pem" ]; do
        echo -n "."
        sleep 0.5
    done
    echo "done."
    if [ "$(id -u)" -eq 0 ]; then
        chown -R "${PUID}:${PGID}" "/home/steam/.mitmproxy"
        chown -R "${PUID}:${PGID}" "${MITMPROXY_ADDONS_DIR}/__pycache__"
    fi

    LogInfo "Update ca-certificates."
    #ln -sf /home/steam/.mitmproxy/mitmproxy-ca-cert.pem /usr/local/share/ca-certificates/mitmproxy.crt
    sudo update-ca-certificates

    LogInfo "Using proxy now."
    export http_proxy="localhost:8080"
    export https_proxy="localhost:8080"
    export no_proxy="localhost,127.0.0.1,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"
fi
