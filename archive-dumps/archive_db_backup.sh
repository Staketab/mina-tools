#!/bin/bash

RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"
UPLOAD="\U1F4E4\n"
GOOD="\U1F7E2\n"
STOP="\U1F6D1\n"

LOG_PATH="$HOME/dumps/archive_$(hostname)_log.txt"

line() {
    echo "-------------------------------------------------------------------"
}
setup() {
  nodename "${1}"
  pgPass "${2}"
  pgDbName "${3}"
  pgUser "${4}"
  bucket "${5}"
  tgtoken "${6}"
  tgchatid "${7}"
  discordhook "${8}"
}
nodename() {
  NODENAME=${1}
}
pgPass() {
  POSTGRES_PASSWORD=${1}
}
pgDbName() {
  POSTGRES_DBNAME=${1}
}
pgUser() {
  POSTGRES_USERNAME=${1}
}
bucket() {
  BLOCKS_BUCKET=${1}
}
tgtoken() {
  TG_TOKEN=${1}
}
tgchatid() {
  TG_CHAT_ID=${1}
}
discordhook() {
  DISCORD_HOOK=${1}
}
set_date() {
    echo -n $(date +%F-%H-%M-%S)
}

logProcess() {
    local logging="$@"
    printf "|$(set_date)| $logging\n" | sudo tee -a ${LOG_PATH}
}
sendTg() {
  if [[ ${TG_TOKEN} != "" ]]; then
    local tg_msg="$@"
    curl -s -H 'Content-Type: application/json' --request 'POST' -d "{\"chat_id\":\"${TG_CHAT_ID}\",\"text\":\"${tg_msg}\"}" "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" -so /dev/null
  fi
}
sendDiscord() {
  if [[ ${DISCORD_HOOK} != "" ]]; then
    local discord_msg="$@"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$discord_msg\"}" $DISCORD_HOOK -so /dev/null
  fi
}
pgDumpCreate() {
  mkdir -p $HOME/dumps
  COMMIT=$(sudo docker exec mina mina client status --json | jq -r '.commit_id' | cut -c 8-)
  DUMP_NAME=$(echo "archive_${NODENAME}_$(date '+%Y-%m-%d')_$COMMIT.dump")
  PGPASSWORD=${POSTGRES_PASSWORD} $(which pg_dump) -Fc -v --host=127.0.0.1 --username=${POSTGRES_USERNAME} --dbname=${POSTGRES_DBNAME} -f $HOME/dumps/${DUMP_NAME}
}
launch() {
  while true
  do
    setup "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}"
    line
    echo -e "$YELLOW Start creating archive database DUMP...$NORMAL"
    line
    logProcess "Start creating archive database DUMP"
    pgDumpCreate
      if [[ -f $HOME/dumps/${DUMP_NAME} ]]; then
        line
        echo -e "$GREEN PG DUMP CREATED.$NORMAL"
        line
        logProcess "PG DUMP CREATED"
        MSG=$(echo -e "$(printf ${GOOD}) | $(date +%F-%H-%M-%S) | ${NODENAME} | PG DUMP CREATED")
        sendTg ${MSG}
        sendDiscord ${MSG}
        logProcess "Removing old DB from GCP"
        OLD_DUMP_NAME="$($(which gsutil) ls gs://${BLOCKS_BUCKET} | egrep -o "archive_$(hostname).*dump")"
        $(which gsutil) rm gs://${BLOCKS_BUCKET}/${OLD_DUMP_NAME}; echo $? >> ${LOG_PATH}
        logProcess "Uploading PG DUMP to GCP"
        $(which gsutil) --quiet cp $HOME/dumps/${DUMP_NAME} gs://${BLOCKS_BUCKET}/${DUMP_NAME}; echo $? >> ${LOG_PATH}
        rm -rf $HOME/dumps/${DUMP_NAME}
        $(which gsutil) du -s -h -a gs://${BLOCKS_BUCKET}/${DUMP_NAME} | sudo tee -a ${LOG_PATH}
        logProcess "DONE\n---------------------------\n"
        MSG=$(echo -e "$(printf ${UPLOAD}) | $(date +%F-%H-%M-%S) | ${NODENAME} | PG DUMP UPLOADED")
        sendTg ${MSG}
        sendDiscord ${MSG}
      else
        line
        echo -e "$RED PG DUMP NOT CREATED...$NORMAL"
        line
        MSG=$(echo -e "$(printf ${STOP}) | $(date +%F-%H-%M-%S) | ${NODENAME} | PG DUMP NOT CREATED | EXIT")
        sendTg ${MSG}
        sendDiscord ${MSG}
        exit 0
      fi
    sleep 24h
  done
}

while getopts ":n:p:d:u:b:t:c:h:" o; do
  case "${o}" in
    n)
      n=${OPTARG}
      ;;
    p)
      p=${OPTARG}
      ;;
    d)
      d=${OPTARG}
      ;;
    u)
      u=${OPTARG}
      ;;
    b)
      b=${OPTARG}
      ;;
    t)
      t=${OPTARG}
      ;;
    c)
      c=${OPTARG}
      ;;
    h)
      h=${OPTARG}
      ;;
  esac
done
shift $((OPTIND-1))

launch "${n}" "${p}" "${d}" "${u}" "${b}" "${t}" "${c}" "${h}"
