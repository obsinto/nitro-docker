#!/bin/bash

supervisord -c /app/supervisor/supervisord.conf

cd /app/arcturus
mvn install
cp /app/config.ini /app/arcturus/target/config.ini

# Compilar plugin NitroWebSocket localmente
cd /app/nitrowebsockets
mvn package

# Copiar plugin compilado para pasta de plugins do emulador
mkdir -p /app/arcturus/target/plugins
cp /app/nitrowebsockets/target/NitroWebsockets-*.jar /app/arcturus/target/plugins/

supervisorctl start arcturus-emulator

tail -f /dev/null