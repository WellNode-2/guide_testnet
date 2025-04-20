#!/bin/bash

TIKER="Drosera"
TRIGGER=10
SERVER_IP=$(hostname -I | awk '{print $1}')
TELEGRAM_TOKEN=""
CHAT_ID=""

send_telegram() {
    local message=$1
    local escaped_ip=$(echo $SERVER_IP | sed 's/\./\\./g')
    local escaped_msg=$(echo "$message" | sed -e 's/>/\\>/g' -e 's/_/\\_/g')
    curl -sS "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d chat_id=${CHAT_ID} -d text="${TIKER}: \`$escaped_ip\`, $escaped_msg" -d parse_mode=MarkdownV2
}

while true; do
    COUNT=$(journalctl -u drosera.service --since "1 hour ago" | grep "rpc" | wc -l)
    if [ "$COUNT" -gt "$TRIGGER" ]; then
        send_telegram "RPC_COUNT: ${COUNT} > ${TRIGGER}"
    fi

    sleep 600
done
