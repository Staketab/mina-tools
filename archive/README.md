# MINA NODE SETUP
Setup Mina node with Archive and uploading blocks to GCloud.

## 1. Setup your GCLOUD service first
## 2. Setup Mina config
Copy your `GCP_KEYFILE` to `$HOME/*`.  

Specify environments in this line `./install.sh -m MINA_IMAGE -a ARCHIVE_IMAGE -k GCP_KEYFILE -b GCP_BUCKET`  
Example `./install.sh -m minaprotocol/mina-daemon-baked:1.1.7-d5ff5aa-mainnet -a minaprotocol/mina-archive:1.1.7-d5ff5aa -k gcp-326118.json -b archive.gcp.com`  
### You can use like all variables or set only `-m MINA_IMAGE` and `-a ARCHIVE_IMAGE`.

## Start this script:
```
wget https://raw.githubusercontent.com/Staketab/mina-tools/main/archive/install.sh \
&& chmod +x install.sh \
&& ./install.sh -m MINA_IMAGE -a ARCHIVE_IMAGE -k GCP_KEYFILE -b GCP_BUCKET
```
## 3. Download docker-compose.yml
```
wget https://raw.githubusercontent.com/Staketab/mina-tools/main/archive/docker-compose.yml
```
## 4. Start the Node
Run this command to start the node:  
```
cd $HOME/tmp
docker-compose up -d
```

Other commands:
1. Check status
```
docker exec -it mina mina client status
```
2. Stop docker-compose
```
docker-compose down
```
3. Docker-compose logs
```
docker-compose logs -f mina
```
```
docker-compose logs -f archive
```

# DONE
