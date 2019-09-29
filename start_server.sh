#!/bin/bash

# default dispatchers
SERVER_IMPL=network
DISPATCHER_IMPL=swinput
SERVER=$(dirname $0)/scripts/server/$SERVER_IMPL/server.sh
DISPATCHER=$(dirname $0)/scripts/dispatcher/$DISPATCHER_IMPL/dispatcher.sh

REMOTE_SERVER_UTILS="scripts/utils"
if [[ -f "${REMOTE_SERVER_UTILS}" ]]
then
    . "${REMOTE_SERVER_UTILS}"
fi

SLEEP_INTERVAL=0.2

AUTHORIZED=false
AUTH_FAIL_CNT=0
USER=einar
PASSWORD=hackner

command_dispatcher()
{
    info_log "Starting dispatcher"
    while (true)
    do
        debug_log "Reading data from user"
        read -n 100  LINE
        debug_log "  - LINE: $LINE"
        if [ ${#LINE} -ge 100 ]
        then
            error_log "Command too big, bailing out"
            exit 1
        fi
        if [ "${LINE}" = "" ]
        then
            info_log "Command empty, bailing out"
            exit 0
        fi
        if [ "$AUTHORIZED" = "false" ]
        then
            COMMAND=$(echo $LINE | awk '{ print $1}')
            REC_USER=$(echo $LINE | awk '{ print $2}')
            REC_PASSWORD=$(echo $LINE | awk '{ print $3}')
            if [ "$COMMAND" = "login" ] && \
                   [ "$REC_USER" = "$USER" ] && \
                   [ "$REC_PASSWORD" = "$PASSWORD" ] 
            then
                echo "login succeded"
                info_log "$USER logged in ($AUTH_FAIL_CNT failed login attempts)"
                AUTHORIZED=true
            else
                echo "login failed"
                error_log "Incorrect user/password $AUTH_FAIL_CNT"
                AUTH_FAIL_CNT=$(( AUTH_FAIL_CNT + 1 ))
                SLEEP_INTERVAL=$(( AUTH_FAIL_CNT * AUTH_FAIL_CNT  ))
                info_log "Sleeping $SLEEP_INTERVAL seconds"
                sleep $SLEEP_INTERVAL
            fi
        else
            echo "OK"
            info_log "Recevied command: $LINE"
	    $DISPATCHER $DISPATCHER_ARGS $LINE
        fi
    done
}

start_server_impl()
{
    while (true)
    do
        $SERVER $SERVER_ARGS
        sleep $SLEEP_INTERVAL
        info_log "Restarting server ($SERVER_IMPL)"
    done
}
    

while [ "$1" != "" ]
do
    case "$1" in
        "--listen-server")
	    start_server_impl
            exit 0
            ;;
        "--server")
	    SERVER=$2
	    shift
            ;;
        "--server-arguments")
	    SERVER_ARGS=$2
	    shift
            ;;
        "--dispatcher")
	    DISPATCHER=$2
            ;;
        "--dispatcher-arguments")
	    DISPATCHER_ARGS=$2
	    shift
            ;;
        "--dispatcher-check")
	    $DISPATCHER --check
	    exit_on_failure $? "$DISPATCHER failure"
            ;;
        "--command-dispatcher")
            command_dispatcher
            exit 0
	    shift
            ;;
        *)
            :
    esac
    shift
done

# Check dispatcher before start
$DISPATCHER --check
exit_on_failure $? "$DISPATCHER failure. Can't run without a working dispatcher. Fix it and check it wih the command: $DISPATCHER --check"

start_server_impl
