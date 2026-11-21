#!/bin/bash

# Detiene el script inmediatamente si algún comando falla
set -e

echo "Iniciando despliegue de Reservify..."

# 1. Actualizar código fuente desde Git (si ya tienes el repo conectado)
echo "Descargando últimos cambios de Git..."
cd ~/projects/reservify-saas && git pull origin main
cd ~/projects/reservify-saas-frontend && git pull origin main

# 2. Construir las imágenes nuevas (Hornear el código)
echo "Construyendo imagen del Backend..."
cd ~/projects/reservify-saas
sudo docker build -t reservify-backend:1.0 .

echo "Construyendo imagen del Frontend..."
cd ~/projects/reservify-saas-frontend
sudo docker build -t reservify-frontend:1.0 .

# 3. Recrear contenedores SIN tocar los volúmenes (Base de datos a salvo)
echo "Actualizando contenedores en Docker Compose..."
cd ~/projects/reservify-deploy
sudo docker compose up -d --force-recreate

# 4. Actualizar estructura de BD (sin borrar datos) y limpiar caché
echo "Ejecutando migraciones pendientes y limpiando caché..."
sudo docker compose exec -T backend php artisan migrate --force
sudo docker compose exec -T backend php artisan optimize:clear

echo "¡Despliegue completado con éxito!"