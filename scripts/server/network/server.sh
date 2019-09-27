#!/bin/bash

REMOTE_SERVER_UTILS="scripts/utils"
if [[ -f "${REMOTE_SERVER_UTILS}" ]]
then
    . "${REMOTE_SERVER_UTILS}"
fi

REMOTE_SERVER="$(dirname $0)/../../../start_server.sh"

REMOTE_PRESS_PORT="9876"

start_server_impl()
{
    info_log "Starting server (and dispatcher)"
    nc -l -p "$REMOTE_PRESS_PORT" | "$REMOTE_SERVER" --command-dispatcher
}

start_server_impl

