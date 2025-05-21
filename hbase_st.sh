#!/bin/bash


if [[ "${HOSTNAME}" == *"hbasem"* ]]; then
    hbase-daemon.sh start master
elif [[ "${HOSTNAME}" == *"regionserver"* ]]; then
    hadoop-daemon.sh start datanode
    yarn-daemon.sh start nodemanager
    hbase-daemon.sh start regionserver
else
    :
fi

tail -f /dev/null
