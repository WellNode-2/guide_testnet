#!/bin/bash

NAME=Sharderium
TELEGRAM_URL=""
TELEGRAM_CHAT_ID=""


send_telegram_message() {
    curl -sS $TELEGRAM_URL \
        -d chat_id=TELEGRAM_CHAT_ID -d parse_mode="Markdown" \
        -d text="$NAME \`$(hostname -I | sed 's/ .*//;')\`
$1"
}

while true; do
    echo "$(date)"

    # Перевіряємо, чи працює контейнер
    CONTAINER_STATUS=$(docker inspect -f '{{.State.Running}}' shardeum-dashboard)
    if [[ "$CONTAINER_STATUS" != "true" ]]; then
        send_telegram_message "Контейнер shardeum-dashboard не запущений. Спроба запуску..."
        docker start shardeum-dashboard
        sleep 10
    fi

    # Отримуємо саме поле state
    STATE=$(docker exec -t shardeum-dashboard operator-cli status | awk '/state:/ {print $NF}' | tr -d '[:space:]')
    echo "Отриманий статус: $STATE"

    # Якщо статус не отримано або він "stopped", спробуємо перезапустити ноду
    if [[ -z "$STATE" || "$STATE" == "stopped" ]]; then
        if [[ -z "$RESTART" ]]; then
            echo "Спроба перезапустити ноду..."
            docker exec -i shardeum-dashboard operator-cli start
            RESTART=1
        else
            # Якщо після перезапуску статус знову не отримано або "stopped"
            if [[ -z "$STATE" ]]; then
                send_telegram_message "Не вдалося отримати статус ноди після перезапуску."
            else
                send_telegram_message "Нода все ще в стані 'stopped' після перезапуску."
            fi
        fi
    elif [[ "$STATE" != "standby" && "$STATE" != "waiting-for-network" && "$STATE" != "active" ]]; then
        # Для інших статусів просто надсилаємо повідомлення
        send_telegram_message "Нода в стані: $STATE"
    else
        # Якщо все добре, скидаємо прапорець
        RESTART=""
        echo "$NAME Нода працює коректно."
    fi

    # Чекаємо 1 годину перед наступним циклом
    sleep 3600
done

