#!/bin/bash

REMOTE_PRESS_PORT=9876

error_log()
{
    echo "ERROR: $*"
}

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
        "left")
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

    echo "Sending \"$KEY\" to swinput"
    echo "$KEY" > /dev/swkeybd
}

listen_server()
{
    echo "Starting server (and dispatcher)"
    nc -l -p $REMOTE_PRESS_PORT | $0 --command-dispatcher
}

command_dispatcher()
{
    echo "Starting dispatcher"
    while read LINE
    do
        echo "Recevied command: $LINE"
        swinput_dispatcher $LINE
    done
}

start_server_impl()
{
    while (true)
    do
        $0 --listen-server
        sleep 1
        echo "Restarting server"
    done
}
    

while [ "$1" != "" ]
do
    case "$1" in
        "--listen-server")
            listen_server
            exit 0
            ;;
        "--command-dispatcher")
            command_dispatcher
            exit 0
            ;;
        "--port")
            REMOTE_PRESS_PORT=$2
            shift
            ;;
        *)
            :
    esac
done

start_server_impl
