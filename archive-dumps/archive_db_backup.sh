#!/bin/bash

RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"
POSTGRES_PASSWORD=${1}
POSTGRES_DBNAME=${2}
POSTGRES_USERNAME=${3}
BLOCKS_BUCKET=${4}
TG_TOKEN=${5}
TG_CHAT_ID=${6}
DISCORD_HOOK=${7}

function line {
    echo "-------------------------------------------------------------------"
}
function sendTg {
  if [[ ${TG_TOKEN} != "" ]]; then
    local tg_msg="$@"
    curl -s -H 'Content-Type: application/json' --request 'POST' -d "{\"chat_id\":\"${TG_CHAT_ID}\",\"text\":\"${tg_msg}\"}" "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" -so /dev/null
  fi
}
function sendDiscord {
  if [[ ${DISCORD_HOOK} != "" ]]; then
    local discord_msg="$@"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"${discord_msg}\"}" $DISCORD_HOOK -so /dev/null
  fi
}
function pgDumpCreate {
  mkdir -p $HOME/dumps
  DUMP_NAME=$(echo "archive_$(hostname)_$(date '+%Y-%m-%d').dump")
  PGPASSWORD=${POSTGRES_PASSWORD} $(which pg_dump) -Fc -v --host=localhost --username=${POSTGRES_USERNAME} --dbname=${POSTGRES_DBNAME} -f $HOME/dumps/${DUMP_NAME}
}
function launch {
  while true
  do
    line
    echo -e "$YELLOW Start creating archive database DUMP...$NORMAL"
    line
    pgDumpCreate
      if [[ -f $HOME/dumps/${DUMP_NAME} ]]; then
        line
        echo -e "$GREEN PG DUMP CREATED.$NORMAL"
        line
        MSG=$(echo -e "$(date +%F-%H-%M-%S) | $HOSTNAME | PG DUMP CREATED")
        sendTg ${MSG}
        sendDiscord ${MSG}
        $(which gsutil) mv ${DUMP_NAME} gs://${BLOCKS_BUCKET}
        MSG=$(echo -e "$(date +%F-%H-%M-%S) | $HOSTNAME | PG DUMP UPLOADED")
        sendTg ${MSG}
        sendDiscord ${MSG}
      else
        line
        echo -e "$RED PG DUMP NOT CREATED...$NORMAL"
        line
        MSG=$(echo -e "$(date +%F-%H-%M-%S) | $HOSTNAME | PG DUMP NOT CREATED | EXIT")
        sendTg ${MSG}
        sendDiscord ${MSG}
        exit 0
      fi
    sleep 24h
  done
}

launch
