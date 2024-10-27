#!/usr/bin/expect

# Установка переменных
set timeout -1

# Извлечение значений из переменных окружения
#set WALLET_ADDRESS [exec env | grep WALLET_ADDRESS | cut -d= -f2]
#set SUBSPACE_NODENAME [exec env | grep SUBSPACE_NODENAME | cut -d= -f2]

# Проверка, установлены ли переменные
set WALLET_ADDRESS stC2C46EFLtcdvPLL74KsRtSkEPMq4LExnRTL2vtc38rPsvr3
if { $WALLET_ADDRESS == "" } {
    puts "Ошибка: WALLET_ADDRESS не установлена"
    exit 1
}

set SUBSPACE_NODENAME WellNode
if { $SUBSPACE_NODENAME == "" } {
    puts "Ошибка: SUBSPACE_NODENAME не установлена"
    exit 1
}

# Запуск команды
spawn /usr/local/bin/pulsar init

# Ответы на вопросы
expect "*farmer/reward address*"
send "y\r"

expect "*your farmer/reward address:*"
send "$WALLET_ADDRESS\r"

expect "*Enter your node name to be identified*"
send "$SUBSPACE_NODENAME\r"

expect "*path for storing farm files*"
send "\r"

expect "*path for storing node files*"
send "\r"

expect "*farm size*"
send "250.0 GB\r"

expect "*Specify the chain to farm*"
send "Gemini3f\r"

expect eof
