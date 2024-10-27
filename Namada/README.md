## UPDATE for new release v0.23.0

```bash
cd $HOME && mkdir $HOME/namada_backup
cp -r $HOME/.local/share/namada/pre-genesis $HOME/namada_backup/
systemctl stop namadad && systemctl disable namadad
rm /usr/local/bin/namada /usr/local/bin/namadac /usr/local/bin/namadan /usr/local/bin/namadaw /usr/local/bin/namadar -rf
rm $HOME/.local/share/namada -rf
rm -rf $HOME/.masp-params

sudo apt update && sudo apt upgrade -y

#CHECK your vars in /.bash_profile and change if they not correctly
sed -i '/public-testnet/d' "$HOME/.bash_profile"
sed -i '/NAMADA_TAG/d' "$HOME/.bash_profile"
sed -i '/WALLET_ADDRESS/d' "$HOME/.bash_profile"

NEWTAG=v0.23.0
NEWCHAINID=public-testnet-14.5d79b6958580

echo "export BASE_DIR=$HOME/.local/share/namada" >> ~/.bash_profile
echo "export NAMADA_TAG=$NEWTAG" >> ~/.bash_profile
echo "export CHAIN_ID=$NEWCHAINID" >> ~/.bash_profile
source ~/.bash_profile

cd $HOME/namada
git fetch && git checkout $NAMADA_TAG
make build-release
cargo fix --lib -p namada_apps

cd $HOME && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && \
cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && \
cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && \
cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw && \
cp "$HOME/namada/target/release/namadar" /usr/local/bin/namadar
systemctl enable namadad

#check version
namada --version
#output: Namada v0.23.0

#ONLY for PRE genesis validator
#IF YOU NOT A PRE GEN VALIDATOR SKIP THIS SECTION
mkdir $HOME/.local/share/namada
cp -r $HOME/namada_backup/pre-genesis* $BASE_DIR/
namada client utils join-network --chain-id $CHAIN_ID --genesis-validator $VALIDATOR_ALIAS

sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat
```


# Local snapshot solution

**Stop your node**
```
systemctl stop namadad && sudo journalctl -u namadad -f -o cat
```

## Saving the snapshot files
```
CHAIN_ID=public-testnet-14.5d79b6958580
mkdir $HOME/snapshot
mv $HOME/.local/share/namada/$CHAIN_ID/db $HOME/snapshot
mv $HOME/.local/share/namada/$CHAIN_ID/cometbft/data $HOME/snapshot
```
  
## Re-join the network
```
cd $HOME/.local/share/namada
rm -rf $CHAIN_ID/ && rm $CHAIN_ID.toml && rm global-config.toml && cd
namadac utils join-network --chain-id $CHAIN_ID --genesis-validator <your-validator-alias>
```
Note: you don't need to use the *--genesis-validator* flag if you are not a pre-genesis validator.
  
**Start your node, wait 30-60s, and stop it**
  
## Applying the snapshot
```
rm -rf $HOME/.local/share/namada/$CHAIN_ID/db
rm -rf $HOME/.local/share/namada/$CHAIN_ID/cometbft/data
cd $HOME/snapshot
mv db/ $HOME/.local/share/namada/$CHAIN_ID
mv data/ $HOME/.local/share/namada/$CHAIN_ID/cometbft
```
  
**Start your node**
```
systemctl restart namadad && sudo journalctl -u namadad -f -o cat
```
