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

if [ "$PIN" = "" ]
then
    export PIN=$(( $RANDOM % 1000))
fi

if [ "$AUTH_METHOD" = "" ]
then
    AUTH_METHOD=user
fi


login_user_password()
{
    L_COMMAND=$1
    L_USER=$2
    L_PASSWORD=$3
    if [ "$L_COMMAND" = "login" ] && \
           [ "$L_USER" = "$USER" ] && \
           [ "$L_PASSWORD" = "$PASSWORD" ] 
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
}

login_pin()
{
    L_COMMAND=$1
    L_PIN=$2
    info_log "Compare $L_PIN with $PIN"
    if [ "$L_COMMAND" = "pin" ] && \
           [ "$L_PIN" = "$PIN" ] 
    then
        echo "login with pin succeded"
        info_log "logged in ($AUTH_FAIL_CNT failed login attempts)"
        AUTHORIZED=true
    else
        echo "login failed"
        error_log "Incorrect pin code $AUTH_FAIL_CNT"
        AUTH_FAIL_CNT=$(( AUTH_FAIL_CNT + 1 ))
        SLEEP_INTERVAL=$(( AUTH_FAIL_CNT * AUTH_FAIL_CNT  ))
        info_log "Sleeping $SLEEP_INTERVAL seconds"
        sleep $SLEEP_INTERVAL
    fi
}

command_dispatcher()
{
    info_log "Log in and then start dispatcher (auth: $AUTH_METHOD)"
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
            debug_log "CHECK \"$LINE\" \"$COMMAND\" "
            debug_log " ---------------------------- auth method: \"$AUTH_METHOD\""
            if [ "$AUTH_METHOD" = "user" ]
            then
                REC_USER=$(echo $LINE | awk '{ print $2}')
                REC_PASSWORD=$(echo $LINE | awk '{ print $3}')
                login_user_password "$COMMAND" "$REC_USER" "$REC_PASSWORD"
            elif [ "$AUTH_METHOD" = "pin" ]
            then
                info_log "doing pin login "
                REC_PIN=$(echo $LINE | awk '{ print $2}')
                login_pin "$COMMAND" "$REC_PIN"
            else
                echo "No login method choosen and you're not authorized"
                exit 1
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
        "--pin-code")
            export AUTH_METHOD=pin
            info_log "pin login $AUTH_METHOD"
            echo "pin code for this session is: $PIN"
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
