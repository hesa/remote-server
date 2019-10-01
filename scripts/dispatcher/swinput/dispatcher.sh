#!/bin/bash

REMOTE_SERVER_UTILS="scripts/utils"
if [[ -f "${REMOTE_SERVER_UTILS}" ]]
then
    . "${REMOTE_SERVER_UTILS}"
fi

REMOTE_SERVER="$(dirname $0)/../../../start_server.sh"


SWINPUT_KBD_DEV=/dev/swkeybd
#
# Dispatcher for SWINPUT / https://github.com/hesa/swinput
#
swinput_dispatcher()
{
    case "$1" in
        "enter")
            KEY="[KEY_ENTER]"
            ;;
        "left")
            KEY="[KEY_LEFT]"
            ;;
        "right")
            KEY="[KEY_RIGHT]"
            ;;
        "down")
            KEY="[KEY_DOWN]"
            ;;
        "up")
            KEY="[KEY_UP]"
            ;;
        *)
            # TODO: only debugging - send a key if failure - 
            KEY="$1"
#            error_log "Failed dispatching: \"$1\""
#           return
    esac

    info_log "Sending \"$KEY\" to swinput"
    echo "$KEY" > "$SWINPUT_KBD_DEV"
}

check_swinput()
{
    info_logn "Checking swinput device: "
    echo "[IGNORE]" > "$SWINPUT_KBD_DEV"
    if [[ $? -eq 0 ]]
    then
	info_logq " OK"
    else
	info_logq " FAILURE"
	exit 1
    fi

}

if [ "$1" = "--check" ]
then
    check_swinput
    exit 0
fi

swinput_dispatcher $1


