#!/bin/bash

[ `whoami` = root ] || exec sudo su -c $0


mkdir -p /home/ubuntu/n8n
touch /home/ubuntu/n8n/.env
cat <<EOT > /home/ubuntu/n8n/.env
POSTGRES_USER=test
POSTGRES_PASSWORD=test
POSTGRES_DB=n8n

POSTGRES_NON_ROOT_USER=test
POSTGRES_NON_ROOT_PASSWORD=test

N8N_BASIC_AUTH_USER=test
N8N_BASIC_AUTH_PASSWORD=test

N8N_WEBHOOK_TUNNEL_URL=http://192.168.1.22/
EOT

touch /home/ubuntu/n8n/docker-compose.yml
cat <<EOT > /home/ubuntu/n8n/docker-compose.yml
version: '3.1'

services:

  postgres:
    image: postgres:11
    restart: always
    environment:
      - POSTGRES_USER
      - POSTGRES_PASSWORD
      - POSTGRES_DB
      - POSTGRES_NON_ROOT_USER
      - POSTGRES_NON_ROOT_PASSWORD
    volumes:
      - ./postgres-data:/var/lib/postgresql/data
      - ./init-data.sh:/docker-entrypoint-initdb.d/init-data.sh

  n8n:
    image: n8nio/n8n
    restart: always
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=\${POSTGRES_DB}
      - DB_POSTGRESDB_USER=\${POSTGRES_NON_ROOT_USER}
      - DB_POSTGRESDB_PASSWORD=\${POSTGRES_NON_ROOT_PASSWORD}
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER
      - N8N_BASIC_AUTH_PASSWORD
      - WEBHOOK_TUNNEL_URL=\${N8N_WEBHOOK_TUNNEL_URL}
    ports:
      - 5678:5678
    links:
      - postgres
    volumes:
      - ./.n8n:/home/node/.n8n
    # Wait 5 seconds to start n8n to make sure that PostgreSQL is ready
    # when n8n tries to connect to it
    command: /bin/sh -c "sleep 5; n8n start"
EOT

touch /home/ubuntu/n8n/init-data.sh
mkdir /home/ubuntu/n8n/postgres-data
chmod +x /home/ubuntu/n8n/init-data.sh
cat <<EOT > /home/ubuntu/n8n/init-data.sh
#!/bin/bash
set -e;


if [ -n "\${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "\${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
	psql -v ON_ERROR_STOP=1 --username "\$POSTGRES_USER" --dbname "\$POSTGRES_DB" <<-EOSQL
		CREATE USER \${POSTGRES_NON_ROOT_USER} WITH PASSWORD '\${POSTGRES_NON_ROOT_PASSWORD}';
		GRANT ALL PRIVILEGES ON DATABASE \${POSTGRES_DB} TO \${POSTGRES_NON_ROOT_USER};
	EOSQL
else
	echo "SETUP INFO: No Environment variables given!"
fi
EOT

cd /home/ubuntu/n8n/ && docker-compose up -d 

exit 0