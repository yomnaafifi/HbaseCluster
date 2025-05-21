#!/bin/bash


if [[ "${HOSTNAME}" == *"hbasem"* ]]; then
    "$HBASE_HOME/bin/hbase-daemon.sh" start master
elif [[ "${HOSTNAME}" == *"regionserver"* ]]; then
    "$HBASE_HOME/bin/hbase-daemon.sh" start regionserver
else
    :
fi

tail -f /dev/null
