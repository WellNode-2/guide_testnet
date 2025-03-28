# Binary Setup
[Офіційна документація](https://docs.t3rn.io/executor/become-an-executor/binary-setup)

## Створення systemd сервісу
~~~bash
sudo tee /etc/systemd/system/t3rn-executor.service > /dev/null <<EOF
[Unit]
Description=t3rn Executor Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$HOME/t3rn/executor/executor/bin
ExecStart=$HOME/t3rn/executor/executor/bin/executor

Environment="ENVIRONMENT=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="EXECUTOR_PROCESS_BIDS_ENABLED=true"
Environment="EXECUTOR_PROCESS_ORDERS_ENABLED=true"
Environment="EXECUTOR_PROCESS_CLAIMS_ENABLED=true"
Environment="EXECUTOR_ENABLE_BATCH_BIDING=true"
Environment="EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true"
Environment="EXECUTOR_PROCESS_ORDERS_API_ENABLED=true"
Environment="EXECUTOR_MAX_L3_GAS_PRICE=1000"
Environment="PRIVATE_KEY_LOCAL=<-PRIVATE_KEY_LOCAL->"
Environment="RPC_ENDPOINTS={\"l2rn\":[\"https://b2n.rpc.caldera.xyz/http\"],\"arbt\":[\"https://arbitrum-sepolia.drpc.org\",\"https://sepolia-rollup.arbitrum.io/rpc\"],\"bast\":[\"https://base-sepolia-rpc.publicnode.com\",\"https://base-sepolia.drpc.org\"],\"opst\":[\"https://sepolia.optimism.io\",\"https://optimism-sepolia.drpc.org\"],\"unit\":[\"https://unichain-sepolia.drpc.org\",\"https://sepolia.unichain.org\"]}"

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
~~~

> **УВАГА:**  
> Ти повинен вказати свій приватний ключ у полі `<-PRIVATE_KEY_LOCAL->`.  

> **Якщо хочеш використовувати свої RPC (а не API):**  
> Замінити рядки:
> ```
> Environment="EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false"
> Environment="EXECUTOR_PROCESS_ORDERS_API_ENABLED=false"
> ```

> Після створення сервісу:
> ```
> sudo systemctl daemon-reload
> sudo systemctl enable t3rn-executor
> sudo systemctl restart t3rn-executor
> journalctl -fu t3rn-executor
> ```
