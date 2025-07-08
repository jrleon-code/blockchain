#!/bin/bash

# Archivo para guardar la dirección actual del contrato
CONTRACT_FILE=".direccion_contrato.txt"

# Cargar dirección desde archivo o usar valor por defecto
if [[ -f "$CONTRACT_FILE" ]]; then
  CONTRACT=$(cat "$CONTRACT_FILE")
else
  CONTRACT="erd1qqqqqqqqqqqqqpgqldncud33rjpaqv4y6kj9hhznrwksrfqwysxqt3pjar"
fi

PEM="./wallet.pem"  # Ruta al archivo .pem del alumno
PROXY="https://devnet-api.multiversx.com"

# Función auxiliar: convierte hexadecimal a decimal
hex_to_decimal() {
  local hex_value=$1
  if [[ $hex_value == "0x"* ]]; then
    hex_value=${hex_value#0x}
  fi
  if [[ -z "$hex_value" || "$hex_value" == "00" || "$hex_value" == "" ]]; then
    echo "0"
  else
    python3 -c "print(int('$hex_value', 16))" 2>/dev/null || echo "0"
  fi
}

# Envía una votación (1 a 5 estrellas)
votar() {
  echo "Contrato actual: $CONTRACT"
  read -p "Introduce la puntuación (1 a 5): " estrellas
  if ! [[ "$estrellas" =~ ^[1-5]$ ]]; then
    echo "Puntuación inválida. Debe ser un número del 1 al 5."
    return
  fi

  mxpy contract call $CONTRACT \
    --pem $PEM \
    --recall-nonce \
    --gas-limit=5000000 \
    --function votar \
    --arguments $estrellas \
    --proxy $PROXY \
    --chain D \
    --send
}

# Consulta la media actual de votos
ver_media() {
  echo "Contrato actual: $CONTRACT"
  result=$(mxpy contract query $CONTRACT \
    --function getMedia \
    --proxy $PROXY 2>/dev/null)

  if [[ $? -eq 0 ]]; then
    hex_media=$(echo "$result" | grep -o '"[^"]*"' | head -1 | tr -d '"')
    decimal=$(hex_to_decimal "$hex_media")
    echo "Media de votos: $decimal estrellas"
  else
    echo "Error al consultar la media"
  fi
}

# Cambia la dirección del contrato en uso
cambiar_contrato() {
  read -p "Introduce nueva dirección del contrato: " nueva
  CONTRACT="$nueva"
  echo "$nueva" > "$CONTRACT_FILE"
  echo "Dirección del contrato actualizada a: $nueva"
}

# Menú de opciones
while true; do
  echo ""
  echo "===== Menú de Evaluación ====="
  echo "Contrato actual: $CONTRACT"
  echo "1) Votar proyecto (1 a 5 estrellas)"
  echo "2) Ver media de votos del proyecto"
  echo "3) Cambiar dirección del contrato"
  echo "0) Salir"
  echo "=============================="
  read -p "Elige una opción: " opcion

  case $opcion in
    1) votar ;;
    2) ver_media ;;
    3) cambiar_contrato ;;
    0) echo "¡Hasta luego!"; break ;;
    *) echo "Opción no válida." ;;
  esac
done
