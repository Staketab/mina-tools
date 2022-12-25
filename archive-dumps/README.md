# Archive automated backup to GCP

## 1. Start

```
wget https://raw.githubusercontent.com/Staketab/mina-tools/main/archive-dumps/archive_db_backup.sh \
&& chmod +x archive_db_backup.sh \
&& ./archive_db_backup.sh -n NODENAME -p PASS -d DB_NAME -u USER -b BUCKET -t TG_TOKEN -c TG_CHAT_ID -h DISCORD_HOOK
```
### DONE
