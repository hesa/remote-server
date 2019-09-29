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
    FIFO=/tmp/remote-server.fifo
    rm -f "$FIFO"
    mkfifo "$FIFO"
    info_log "Starting server (and dispatcher)"
    cat "$FIFO" | "$REMOTE_SERVER" --command-dispatcher -i 2>&1 | nc -l -p "$REMOTE_PRESS_PORT" > $FIFO
#    nc -l -p  | 
}

start_server_impl

