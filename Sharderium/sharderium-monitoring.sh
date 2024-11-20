#!/bin/bash

NAME="Sharderium"
TELEGRAM_TOKEN=""
TELEGRAM_CHAT_ID=""
RESTART_STATUS=0

send_telegram_message() {
    curl -sS "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" -d parse_mode="Markdown" \
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

    if [[ -z "$STATE" || "$STATE" == "stopped" ]]; then
        if [[ "$RESTART_STATUS" -eq 1 ]]; then
            send_telegram_message "Нода все ще в стані 'stopped' після спроби перезапуску."
        fi
        echo "Спроба перезапустити ноду..."
        docker exec -i shardeum-dashboard operator-cli start
        RESTART_STATUS=1
    elif [[ "$STATE" =~ ^(standby|waiting-for-network|active|ready|syncing|selected)$ ]]; then
        echo "$NAME Нода працює коректно."
        RESTART_STATUS=0
    else
        send_telegram_message "Нода в невідомому стані: $STATE."
    fi

    sleep 3600
done
