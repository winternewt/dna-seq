#!/bin/bash
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
if ! [ $(id -u) = 0 ]; then
   echo "Must be root!"
   exit 1
fi
docker system prune -a
rm -rf /data/cromwell-executions/
rm -rf /data/cromwell-workflow-logs/workflow.*
rm -rf /data/databases/mysql/*
cd ${ABSDIR}/../
git restore ./data/cromwell-executions/.gitignore
cd -