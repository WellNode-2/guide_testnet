# Налаштування та запуск ноди Warden Protocol (Testnet)

## Офіційна документація 
https://docs.wardenprotocol.org/operate-a-node/create-a-validator

## Оновлення системи
```bash
apt update && sudo apt upgrade -y && \
apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu libleveldb-dev htop screen unzip fail2ban htop lz4 bc -y
```

## Установлення Go
```bash
ver="1.23.8" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
```

## Завантаження та збірка Warden
```bash
git clone https://github.com/warden-protocol/wardenprotocol.git
cd wardenprotocol
make install
```

## Перевірка установки
```bash
wardend version --long
```

## Ініціалізація ноди
```bash
wardend init <your_moniker> --chain-id=chiado_10010-1
```

## Завантаження genesis
```bash
wget -O $HOME/.warden/config/genesis.json https://raw.githubusercontent.com/warden-protocol/networks/main/testnets/chiado/genesis.json
```

## Редагування config.toml
SEEDS="2d2c7af1c2d28408f437aef3d034087f40b85401@52.51.132.79:26656"
PEERS=""
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.warden/config/config.toml


## Створення systemd сервісу
```bash
sudo tee /etc/systemd/system/wardend.service > /dev/null <<EOF
[Unit]
Description=Warden Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which wardend) start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
```

```bash
sudo systemctl daemon-reload && sudo systemctl enable wardend
sudo systemctl restart wardend && sudo journalctl -u wardend -fo cat
```

## Створення гаманця
⚠️ **НЕ ПЕРЕДАВАЙТЕ мнемонічну фразу нікому та не вставляйте її у скрипти!**
```bash
wardend keys add <wallet_name>

# Або для відновлення:
wardend keys add <wallet_name> --recover
```

## Отримання тестових токенів в дискорді проекта


## Створення файл валідатора validator.json 
```bash
{
  "pubkey": {
    "@type": "/cosmos.crypto.ed25519.PubKey",
    "key": "lR1d7YBVK5jYijOfWVKRFoWCsS4dg3kagT7LB9GnG8I="
  },
  "amount": "1000000000000000000award",
  "moniker": "your validator human-readable name (moniker)",
  "identity": "your validator identity signature",
  "website": "(optional) your validator website",
  "security": "(optional) your validator security contact",
  "details": "(optional) your validator details",
  "commission-rate": "0.1",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
```

## Надсилання транзакцію для створення валідатора:
```bash
wardend tx staking create-validator validator.json \
  --from=my-key-name \
  --chain-id=chiado_10010-1 \
  --fees=250000000000000award \
  --gas auto \
  --gas-adjustment 1.6
```
