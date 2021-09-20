#!/bin/bash

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
&& wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
&& sudo apt-get update \
&& sudo apt-get -y install postgresql

sudo -i -u postgres psql -U postgres --command "ALTER USER postgres WITH PASSWORD '"${PASS}"';"
sudo -i -u postgres psql -U postgres --command "CREATE DATABASE archive"
sudo -i -u postgres psql -U postgres -d archive --command "$(curl -Ls https://raw.githubusercontent.com/Staketab/mina-tools/main/archive/pginit/mina_schema.sql)"
