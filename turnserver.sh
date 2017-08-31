#!/bin/bash

if [ -z $SKIP_AUTO_IP ] && [ -z $EXTERNAL_IP ]
then
    if [ ! -z USE_IPV4 ]
    then
        EXTERNAL_IP=`curl -4 icanhazip.com 2> /dev/null`
    else
        EXTERNAL_IP=`curl icanhazip.com 2> /dev/null`
    fi
fi

if [ -z $PORT ]
then
    PORT=3478
fi


if [ -z $NO_NEW_CONFIG ]
then
    if [ ! -e /tmp/turnserver.configured ]
    then
        if [ -z $SKIP_AUTO_IP ]
        then
            echo external-ip=$EXTERNAL_IP > /etc/turnserver.conf
        fi
        echo listening-port=$PORT >> /etc/turnserver.conf

        if [ ! -z $LISTEN_ON_PUBLIC_IP ]
        then
            echo listening-ip=$EXTERNAL_IP >> /etc/turnserver.conf
        fi

        touch /tmp/turnserver.configured
    fi

    if [ ! -z $ENABLE_SSL ]
    then
        if [ ! -z $SSL_CRT_FILE ]
        then
            echo cert=$SSL_CRT_FILE >> /etc/turnserver.conf
        else
            echo cert=/etc/cert/server.crt >> /etc/turnserver.conf
        fi
        
        if [ ! -z $SSL_KEY_FILE ]
        then
            echo pkey=$SSL_KEY_FILE >> /etc/turnserver.conf
        else
            echo pkey=/etc/cert/server.key >> /etc/turnserver.conf
        fi
    fi

    # min port 
    if [ -z $MIN_PORT ]
    then
        echo min-port=49152 >> /etc/turnserver.conf
    else    
        echo min-port=$MIN_PORT >> /etc/turnserver.conf
    fi

    # max port 
    if [ -z $MAX_PORT ]
    then
        echo max-port=65535 >> /etc/turnserver.conf
    else    
        echo max-port=$MAX_PORT >> /etc/turnserver.conf
    fi

    if [ ! -z $ENABLE_SQLITE ]
    then
        echo userdb=/var/lib/turn/turndb >> /etc/turnserver.conf
    fi

    if [ ! -z $ENABLE_MOBILITY ]
    then
        echo mobility >> /etc/turnserver.conf
    fi

    if [ ! -z $USERNAME ] && [ ! -z $PASSWORD ]
    then
        echo lt-cred-mech >> /etc/turnserver.conf
        echo user=$USERNAME:$PASSWORD >> /etc/turnserver.conf
    fi

    if [ ! -z $REALM ]
    then
        echo realm=$REALM >> /etc/turnserver.conf
    fi

    if [ ! -z $RELAY_IP ]
    then
        echo relay-ip=$RELAY_IP >> /etc/turnserver.conf
    fi

    if [ ! -z $STATIC_AUTH_SECRET ]
    then
        echo lt-cred-mech >> /etc/turnserver.conf
        echo static-auth-secret=$STATIC_AUTH_SECRET >> /etc/turnserver.conf
    fi
fi

exec /usr/bin/turnserver -c /etc/turnserver.conf --no-cli -l stdout
