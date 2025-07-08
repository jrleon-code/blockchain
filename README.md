# Proyecto de Evaluación Blockchain en MultiverseX

Este proyecto permite que los alumnos voten trabajos de sus compañeros con puntuaciones simbólicas de 1 a 5 estrellas, registradas en la blockchain de devnet de MultiverseX.

## Componentes

- `lib.rs`: Smart contract que gestiona las votaciones.
- `cliente.sh`: Script Bash para que cada alumno pueda votar y consultar la media.
- `wallet.pem`: Archivo de clave privada del alumno (no incluido).

## Requisitos

- Tener instalada `mxpy` (herramienta de línea de comandos de MultiversX).
- Tener una wallet en devnet con algo de balance (no se consume EGLD en esta demo).
- Permisos de ejecución sobre `cliente.sh` (`chmod +x cliente.sh`).

## Cómo desplegar un contrato

1. Compilar el smart contract:
   ```
   mxpy contract build
   ```

2. Desplegar el contrato:
   ```
   mxpy contract deploy --project . --pem wallet.pem --gas-limit=5000000 --proxy https://devnet-api.multiversx.com --chain D --send
   ```

   Guarda la dirección del contrato desplegado.

3. Actualiza la variable `CONTRACT=` en `cliente.sh` con esa dirección.

## Cómo votar

1. Ejecuta:
   ```
   ./cliente.sh
   ```

2. Usa la opción 1 para votar (solo una vez por contrato).
3. Usa la opción 2 para consultar la media de votos actual.

## Evaluación

Cada alumno vota una vez a cada contrato de sus compañeros. El sistema impide votos duplicados y solo permite puntuaciones válidas.
