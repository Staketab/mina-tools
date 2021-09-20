#!/bin/bash

RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"
NODE_IP="$(curl ifconfig.me)"

function setup {
  minaTag "${1}"
  archiveTag "${2}"
  gcpKeyfile "${3}"
  gcpBucket "${4}"
}

function minaTag {
  MINA_IMAGE=${1}
}

function archiveTag {
  ARCHIVE_IMAGE=${1}
}

function gcpKeyfile {
  GCP_KEYFILE=${1}
}

function gcpBucket {
  GCP_BUCKET=${1}                         # archive.gcp.com
}

function update {
curl -s https://raw.githubusercontent.com/Staketab/node-tools/main/components/docker/install.sh | bash
}

function install {
setup "${1}" "${2}" "${3}" "${4}"
echo -e "$YELLOW Components updated.$NORMAL"
echo "-------------------------------------------------------------------"
echo -e "$YELLOW Enter PASSWORD for postgres user $NORMAL"
echo "-------------------------------------------------------------------"
read -s PASS
export PASS=${PASS}

sudo iptables -A INPUT -p tcp --dport 8302:8302 -j ACCEPT
mkdir $HOME/keys
chmod 700 $HOME/keys
chmod 600 $HOME/keys/my-wallet

cd
mkdir $HOME/tmp

sudo /bin/bash -c  'echo "MINA='${MINA_IMAGE}'
ARCHIVE='${ARCHIVE_IMAGE}'
PEER_LIST=https://storage.googleapis.com/mina-seed-lists/mainnet_seeds.txt
PGUSER=postgres
PGPASSWORD='${PASS}'
PGURI=postgres://localhost:5432/archive
GCLOUD_KEYFILE='${GCP_KEYFILE}'
NETWORK_NAME=mainnet
GCLOUD_BLOCK_UPLOAD_BUCKET='${GCP_BUCKET}'" > $HOME/tmp/.env'

echo -e "$YELLOW ENV for docker-compose created.$NORMAL"
echo "-------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/Staketab/mina-tools/main/archive/pginit/init-mina-db.sh | bash

echo -e "$GREEN POSTGRESQL installed.$NORMAL"
echo "-------------------------------------------------------------------"

echo -e "$GREEN ALL settings and configs created.$NORMAL"
echo "-------------------------------------------------------------------"

cd
}

while getopts ":m:a:k:b:" o; do
  case "${o}" in
    m)
      m=${OPTARG}
      ;;
    a)
      a=${OPTARG}
      ;;
    k)
      k=${OPTARG}
      ;;
    b)
      b=${OPTARG}
      ;;
  esac
done
shift $((OPTIND-1))

update
install "${m}" "${a}" "${k}" "${b}"
