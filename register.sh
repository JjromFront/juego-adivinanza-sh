#!/bin/bash

# Datos del usuario
read -p "Nombre del usuario: " name

# Conectarse a la base de datos (asegúrate de cambiar estos valores)
DB_USER="postgres"
DB_PASSWORD="tu_contraseña_de_bd"
DB_NAME="riddlegame"
SCHEMA="public"  # Cambia 'tu_esquema' al nombre de tu esquema

# Ejecutar una consulta SQL para insertar el usuario y obtener su ID
query="INSERT INTO $SCHEMA.user (name, register_date) VALUES ('$name', NOW()) RETURNING user_id;"

# Ejecutar la consulta y guardar el resultado en una variable
user_id=$(psql -U $DB_USER -d $DB_NAME -t -c "$query")

# Imprimir el ID del usuario registrado
echo "Usuario registrado con ID: $user_id"