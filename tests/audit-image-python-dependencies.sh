#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s IMAGE\n' "${0##*/}" >&2
}

if [[ "$#" -ne 1 || -z "$1" ]]; then
    usage
    exit 2
fi

image="$1"

for required_command in docker python3 mktemp find; do
    if ! command -v "${required_command}" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "${required_command}" >&2
        exit 127
    fi
done

if ! docker image inspect "${image}" >/dev/null 2>&1; then
    printf 'Docker image not found locally: %s\n' "${image}" >&2
    exit 1
fi

temporary_directory="$(mktemp -d)"
audit_venv="${temporary_directory}/pip-audit-venv"
container_id=""
trap '
    docker rm "${container_id}" >/dev/null 2>&1 || true
    rm -rf "${temporary_directory}"
' EXIT

if ! python3 -m venv "${audit_venv}"; then
    printf 'Could not create a temporary Python environment for pip-audit.\n' >&2
    exit 1
fi
if ! "${audit_venv}/bin/python" -m pip install \
    --disable-pip-version-check --no-cache-dir pip-audit; then
    printf 'Could not install pip-audit in its temporary environment.\n' >&2
    exit 1
fi

pip_audit="${audit_venv}/bin/pip-audit"
container_id="$(docker create "${image}")"

copy_site_packages() {
    local venv_name="$1"
    local venv_lib="${temporary_directory}/${venv_name}-lib"
    local site_packages

    mkdir -p "${venv_lib}"
    if ! docker cp "${container_id}:/opt/${venv_name}-venv/lib/." "${venv_lib}/"; then
        printf 'Could not copy %s Python packages from image.\n' "${venv_name}" >&2
        return 1
    fi

    site_packages="$(find "${venv_lib}" -type d -name site-packages -print -quit)"
    if [[ -z "${site_packages}" ]]; then
        printf 'No site-packages directory found for %s in image.\n' "${venv_name}" >&2
        return 1
    fi

    printf '%s\n' "${site_packages}"
}

audit_status=0
for venv_name in api-proxy mitmproxy; do
    printf 'Auditing %s dependencies in image %s\n' "${venv_name}" "${image}"
    if ! site_packages="$(copy_site_packages "${venv_name}")"; then
        audit_status=1
        continue
    fi
    if ! "${pip_audit}" --path "${site_packages}"; then
        audit_status=1
    fi
done

exit "${audit_status}"