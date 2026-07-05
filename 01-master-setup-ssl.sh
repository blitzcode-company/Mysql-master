#!/bin/bash
set -e

# CORRER EN EL MASTER (192.168.1.105)
PROJECT_DIR="/home/Mysql-master"
SSL_DIR="${PROJECT_DIR}/mysql-ssl"
COMPOSE_FILE="${PROJECT_DIR}/docker-compose.yml"
MYCNF_FILE="${PROJECT_DIR}/my.cnf"
CONTAINER_NAME="mysql-master"
ROOT_PASSWORD="Blitzcode1."
REPL_USER="repl"
REPL_PASSWORD="Blitzcode1."

echo "== 1. Generando certificados en ${SSL_DIR} =="
mkdir -p "${SSL_DIR}"
cd "${SSL_DIR}"

if [ -f ca.pem ]; then
  echo "Ya existe ca.pem, no se regenera la CA."
else
  openssl genrsa 2048 > ca-key.pem
  openssl req -new -x509 -nodes -days 3650 -key ca-key.pem -out ca.pem -subj "/CN=Blitzvideo-CA"
fi

if [ -f server-cert.pem ]; then
  echo "Ya existe server-cert.pem del master, se omite."
else
  openssl req -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-req.pem -subj "/CN=mysql-master"
  openssl rsa -in server-key.pem -out server-key.pem
  openssl x509 -req -in server-req.pem -days 3650 -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem
fi

if [ -f client-cert.pem ]; then
  echo "Ya existe client-cert.pem (repl), se omite."
else
  openssl req -newkey rsa:2048 -days 3650 -nodes -keyout client-key.pem -out client-req.pem -subj "/CN=repl-client"
  openssl rsa -in client-key.pem -out client-key.pem
  openssl x509 -req -in client-req.pem -days 3650 -CA ca.pem -CAkey ca-key.pem -set_serial 02 -out client-cert.pem
fi

echo "== 2. Ajustando permisos =="
chmod 644 *.pem
chmod 640 *-key.pem

echo "== Ajustando dueño a uid 999 (usuario mysql dentro del contenedor) =="
if chown -R 999:999 . 2>/dev/null; then
  echo "chown a 999:999 aplicado correctamente."
else
  echo "No se pudo hacer chown (¿no sos root?). Aplicando chmod 644 a todo como fallback."
  chmod 644 *.pem
fi
cd - > /dev/null

echo "== 3. Verificando volumen SSL en docker-compose.yml =="
if grep -q "mysql-ssl:/etc/mysql/ssl" "${COMPOSE_FILE}"; then
  echo "El volumen SSL ya está en ${COMPOSE_FILE}, no se toca."
else
  echo ""
  echo "ATENCION: agregá manualmente esta línea dentro de 'volumes:' del servicio en ${COMPOSE_FILE}:"
  echo "      - ./mysql-ssl:/etc/mysql/ssl:ro"
  echo ""
fi

echo "== 4. Verificando my.cnf =="
if grep -q "ssl-ca=/etc/mysql/ssl/ca.pem" "${MYCNF_FILE}"; then
  echo "my.cnf ya tiene la config SSL, no se toca."
else
  cat >> "${MYCNF_FILE}" << 'INNEREOF'

ssl-ca=/etc/mysql/ssl/ca.pem
ssl-cert=/etc/mysql/ssl/server-cert.pem
ssl-key=/etc/mysql/ssl/server-key.pem
INNEREOF
  echo "Se agregaron las líneas SSL a ${MYCNF_FILE}"
fi

echo ""
echo "== LISTO =="
echo "Ahora tenés que:"
echo "1. Confirmar el volumen SSL en tu docker-compose.yml (ver arriba si hizo falta)."
echo "2. Reiniciar el master:"
echo "     cd ${PROJECT_DIR} && docker compose down && docker compose up -d"
echo "3. Seguir con 02-copy-certs-to-slave.sh"
