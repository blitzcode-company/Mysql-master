#!/bin/bash
set -e

# ============================================================
# EDITAR: usuario con el que te conectás a cada servidor
# Correr este script DESDE EL MASTER (192.168.1.105)
# ============================================================
SSH_USER="root"                 # <-- cambiar si usás otro usuario
SLAVE_HOST="192.168.1.106"
# ============================================================

echo "== Generando clave SSH en el master (si no existe ya) =="
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
else
  echo "Ya existe ~/.ssh/id_rsa, se reutiliza."
fi

echo ""
echo "== Copiando la clave pública al slave (te va a pedir la password de ${SSH_USER}@${SLAVE_HOST} UNA vez) =="
ssh-copy-id "${SSH_USER}@${SLAVE_HOST}"

echo ""
echo "== Probando conexión sin password =="
ssh "${SSH_USER}@${SLAVE_HOST}" "echo Conexion SSH sin password: OK"

echo ""
echo "LISTO. Ahora el scp entre master y slave va a funcionar sin pedir password."
