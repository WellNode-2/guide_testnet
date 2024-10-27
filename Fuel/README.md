# Fuel Beta-5 Setup // Testnet — Beta-5
https://docs.fuel.network/guides/running-a-node/running-a-testnet-node/

### Install rust
~~~
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
~~~
~~~
source "$HOME/.cargo/env"
~~~

### Run fuelup-init
~~~
curl -sSf https://install.fuel.network/fuelup-init.sh | sh
~~~

### Add path
~~~
echo 'export PATH=$PATH:/home/fuel/.fuelup/bin' >> ~/.bashrc
source ~/.bashrc
fuelup --version
~~~

### Genereate P2P key
~~~
fuel-core-keygen new --key-type peering
~~~

### Download chain config
~~~
wget -O chainConfig.json https://raw.githubusercontent.com/FuelLabs/fuel-core/v0.22.0/deployment/scripts/chainspec/beta_chainspec.json
~~~

### Create service file
ENDPOINT=<Your_Ethereum_Sepolia_Endpoint>  
KEYPAR=<Your_P2P_Key_Secret>

~~~
sudo tee /etc/systemd/system/fueld.service > /dev/null <<EOF
[Unit]
Description=FuelNode5
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME
ExecStart=$(which fuel-core) run \
--service-name FuelNode \
--keypair $KEYPAR \
--relayer $ENDPOINT \
--ip 0.0.0.0 --port 4000 --peering-port 30333 \
--db-path  ~/.fuel_beta5 \
--chain ./chainConfig.json \
--utxo-validation --poa-instant false --enable-p2p \
--min-gas-price 1 --max-block-size 18874368  --max-transmit-size 18874368 \
--reserved-nodes /dns4/p2p-beta-5.fuel.network/tcp/30333/p2p/16Uiu2HAmSMqLSibvGCvg8EFLrpnmrXw1GZ2ADX3U2c9ttQSvFtZX,/dns4/p2p-beta-5.fuel.network/tcp/30334/p2p/16Uiu2HAmVUHZ3Yimoh4fBbFqAb3AC4QR1cyo8bUF4qyi8eiUjpVP \
--sync-header-batch-size 100 \
--enable-relayer \
--relayer-v2-listening-contracts 0x557c5cE22F877d975C2cB13D0a961a182d740fD5 \
--relayer-da-deploy-height 4867877 \
--relayer-log-page-size 2000
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
~~~

### Enable and start service
~~~
sudo systemctl daemon-reload
sudo systemctl enable fueld
sudo systemctl restart fueld && sudo journalctl -u fueld -f
~~~
