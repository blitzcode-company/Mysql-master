#!/bin/bash
set -e

# CORRER EN EL MASTER (192.168.1.105), despues de reiniciar el contenedor con SSL
CONTAINER_NAME="mysql-master"
ROOT_PASSWORD="Blitzcode1."
REPL_USER="repl"
REPL_PASSWORD="Blitzcode1."

echo "== Verificando si el usuario ${REPL_USER} ya existe =="
EXISTS=$(docker exec -i "${CONTAINER_NAME}" mysql -uroot -p"${ROOT_PASSWORD}" -N -B \
  -e "SELECT COUNT(*) FROM mysql.user WHERE user='${REPL_USER}';")

if [ "${EXISTS}" -gt 0 ]; then
  echo "El usuario ya existe, actualizando para exigir SSL..."
  docker exec -i "${CONTAINER_NAME}" mysql -uroot -p"${ROOT_PASSWORD}" -e "
    ALTER USER '${REPL_USER}'@'%' REQUIRE SSL;
    FLUSH PRIVILEGES;
  "
else
  echo "El usuario no existe, creándolo con SSL obligatorio..."
  docker exec -i "${CONTAINER_NAME}" mysql -uroot -p"${ROOT_PASSWORD}" -e "
    CREATE USER '${REPL_USER}'@'%' IDENTIFIED BY '${REPL_PASSWORD}' REQUIRE SSL;
    GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'%';
    FLUSH PRIVILEGES;
  "
fi

echo ""
echo "== Estado del master (File/Position, por si hiciera falta) =="
docker exec -i "${CONTAINER_NAME}" mysql -uroot -p"${ROOT_PASSWORD}" -e "SHOW MASTER STATUS;"

echo ""
echo "== LISTO =="
echo "Ahora andá al SLAVE (192.168.1.106) y corré 05-migrate-replication-to-ssl.sh"
