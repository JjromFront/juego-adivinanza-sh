#!/bin/bash

# Configuración de la base de datos PostgreSQL
DB_USER="postgres"
DB_PASSWORD="tu_contraseña"
DB_NAME="riddlegame"
DB_HOST="localhost" # Cambia esto si tu base de datos está en otro lugar
SCHEMA_NAME="public" # Cambia esto al nombre de tu esquema

# Obtén el ID del usuario
read -p "Ingresa tu ID de usuario: " user_id

# Verifica si el usuario existe en la otra base de datos
user_exists=$(psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SELECT 1 FROM $SCHEMA_NAME.user WHERE user_id = $user_id")

if [ -z "$user_exists" ]; then
    echo "El ID de usuario no existe en la otra base de datos."
    exit 1
fi

# Registra la fecha actual
register_date=$(date +"%Y-%m-%d %H:%M:%S")

# Genera un número aleatorio entre 1 y 100
random_number=$(( (RANDOM % 100) + 1 ))

# Comienza el juego
echo "¡Bienvenido al juego de adivinanza de números!"
echo "Tienes 1 minuto para adivinar el número entre 1 y 100."
echo "Comienza a adivinar..."

start_time=$(date +%s)
attempts=0
credits=100

while true; do
    read -p "Introduce tu adivinanza: " guessed_number

    # Verifica si la suposición es válida
    if ! [[ "$guessed_number" =~ ^[0-9]+$ ]]; then
        echo "Por favor, ingresa un número válido."
        continue
    fi

    ((attempts++))

    # Compara la suposición con el número aleatorio
    if [ "$guessed_number" -lt "$random_number" ]; then
        echo "El número es mayor. Sigue intentando."
    elif [ "$guessed_number" -gt "$random_number" ]; then
        echo "El número es menor. Sigue intentando."
    else
        echo "¡Felicidades! Has adivinado el número en $attempts intentos."

        # Calcula el puntaje basado en el tiempo y los intentos
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        max_score=100
        time_factor=$((60 - elapsed_time))
        score=$((attempts * (max_score - time_factor) / 60))

        # Asegura que el puntaje no sea negativo
        if [ $score -lt 0 ]; then
            score=0
        fi

        echo "Tu puntaje es: $score puntos."

        break
    fi

    # Verifica el tiempo transcurrido
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [ $elapsed_time -ge 60 ]; then
        echo "Se acabó el tiempo. Has agotado tus intentos."
        break
    fi
done

# Registra el juego en la tabla 'game' del esquema
psql -h $DB_HOST -U $DB_USER -d $DB_NAME <<EOF
INSERT INTO $SCHEMA_NAME.game (user_id, guessed_number, attempts_made, credits_made)
VALUES ($user_id, '$guessed_number', $attempts, $credits);
EOF

echo "Gracias por jugar. Tu partida ha sido registrada en la base de datos."