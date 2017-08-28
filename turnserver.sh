#!/bin/bash

# long-term credential mechanism
echo 'lt-cred-mech' > /etc/turnserver.conf

# port 
if [ -z $PORT ]
then
    echo listening-port=3478 >> /etc/turnserver.conf
else    
    echo listening-port=$PORT >> /etc/turnserver.conf
fi

# tls port 
if [ -z $PORT ]
then
    echo tls-listening-port=5349 >> /etc/turnserver.conf
else    
    echo tls-listening-port=$PORT >> /etc/turnserver.conf
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

# external ip 
if [ -z $EXTERNAL_IP ]
then
    if [ ! -z USE_IPV4 ]
    then
        EXTERNAL_IP=`curl -4 icanhazip.com 2> /dev/null`
    else
        EXTERNAL_IP=`curl icanhazip.com 2> /dev/null`
    fi
fi
echo external-ip=$EXTERNAL_IP >> /etc/turnserver.conf

# listening ip
if [ ! -z $LISTEN_ON_PUBLIC_IP ]
then
    echo listening-ip=$EXTERNAL_IP >> /etc/turnserver.conf
fi

# ssl
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

# db sqlite
if [ ! -z $ENABLE_SQLITE ]
then
    echo userdb=/var/lib/turn/turndb >> /etc/turnserver.conf
fi

# mobility
if [ ! -z $ENABLE_MOBILITY ]
then
    echo mobility >> /etc/turnserver.conf
fi

# realm
if [ ! -z $REALM ]
then
    echo realm=$REALM >> /etc/turnserver.conf
fi

# username:password auth
if [ ! -z $USERNAME ] && [ ! -z $PASSWORD ]
then
    echo lt-cred-mech >> /etc/turnserver.conf
    echo user=$USERNAME:$PASSWORD >> /etc/turnserver.conf
fi

# static secret auth
if [ ! -z $STATIC_AUTH_SECRET ]
then
    echo lt-cred-mech >> /etc/turnserver.conf
    echo static-auth-secret=$STATIC_AUTH_SECRET >> /etc/turnserver.conf
fi

exec /usr/bin/turnserver -c /etc/turnserver.conf --no-cli -l stdout