#!/bin/bash
set -e

# CORRER EN EL MASTER (192.168.1.105)
SSL_DIR="/home/Mysql-master/mysql-ssl"
SLAVE_USER="root"
SLAVE_HOST="192.168.1.106"
SLAVE_SSL_DIR="/home/Mysql-slave/mysql-ssl"

echo "== Creando carpeta destino en el slave (si no existe) =="
ssh "${SLAVE_USER}@${SLAVE_HOST}" "mkdir -p ${SLAVE_SSL_DIR}"

echo "== Copiando ca.pem, ca-key.pem, client-cert.pem, client-key.pem =="
scp "${SSL_DIR}/ca.pem" "${SLAVE_USER}@${SLAVE_HOST}:${SLAVE_SSL_DIR}/"
scp "${SSL_DIR}/ca-key.pem" "${SLAVE_USER}@${SLAVE_HOST}:${SLAVE_SSL_DIR}/"
scp "${SSL_DIR}/client-cert.pem" "${SLAVE_USER}@${SLAVE_HOST}:${SLAVE_SSL_DIR}/"
scp "${SSL_DIR}/client-key.pem" "${SLAVE_USER}@${SLAVE_HOST}:${SLAVE_SSL_DIR}/"

echo ""
echo "== LISTO =="
echo "Ahora andá al servidor SLAVE (192.168.1.106) y corré 03-slave-setup-ssl.sh"
