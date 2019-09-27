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


command_dispatcher()
{
    info_log "Starting dispatcher"
    while read LINE
    do
        info_log "Recevied command: $LINE"
	$DISPATCHER $DISPATCHER_ARGS $LINE
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
