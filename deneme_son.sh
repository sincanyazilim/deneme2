sudo apt update && sudo apt upgrade -y
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

if ! [ -x "$(command -v go)" ]; then
cd $HOME
wget -O go1.19.2.linux-amd64.tar.gz https://golang.org/dl/go1.19.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz && rm go1.19.2.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
go version
fi

cd $HOME
git clone https://github.com/NibiruChain/nibiru
cd nibiru
git checkout v0.15.0
make build

NODENAME=KKMNKR

nibid init $NODENAME --chain-id nibiru-testnet-1

nibid config keyring-backend test
nibid config chain-id nibiru-testnet-1
nibid config node tcp://localhost:26657


curl -s https://rpc.testnet-1.nibiru.fi/genesis | jq -r .result.genesis > genesis.json
cp genesis.json $HOME/.nibid/config/genesis.json


PEERS="5c30c7e8240f2c4108822020ae95d7b5da727e54@65.108.75.107:19656,0e74d23d31bde15e0706e1e4bf0e87c70ae75ec8@154.26.137.8:26656,da6cabfdbb17e1eb03ae3fbf9fab2f9444e2eec8@194.5.152.22:26656,eb3cefa339eea87f2b7ce6f64b1ebff273d10903@193.46.243.254:26656,833a4ce4b51c81bbbb41dad7ff9733080e8232e9@154.26.132.181:26656,5eecfdf089428a5a8e52d05d18aae1ad8503d14c@65.108.141.109:19656,cb3c8df3e1d8942de9908bc1e5bb371a5671c404@89.163.231.30:36656,6c36e166abed836e188c28bbec8d60b235def7d7@45.142.214.97:26656,095cc77588be94bc2988b4dba86bfb001ec925ff@135.181.111.204:26656,2fc98a228dee1826d67e8a2dbd553989118a49cc@5.9.22.14:60656,a4264e666b89f2a6ac59dbf4e33e23e9cbe8c51b@194.233.74.26:26656,ff597c3eea5fe832825586cce4ed00cb7798d4b5@65.109.53.53:26656,95514d97c9d0776478bee64353d986583a95c72e@185.135.137.193:26656,5e65a3d32678a7206d006f899be707c130a9ada1@162.55.234.70:55356,8641bef617e5b38290be2eee2ea031a36855c901@65.108.216.139:26656,722f2c0a8d0aaabbc3b8701d98ab9766686f63ac@95.216.142.94:36656,04dcccb784be8380a4849e32c3bbb9e8ea8b9a95@45.91.171.75:23656,3cc4ba658dde90f2276455bb64a4efb666e1bc22@38.242.224.226:46656,456c75e3d465d34a22a976afb17e96e85947de75@167.99.36.201:26656,7ddc65049ebdab36cef6ceb96af4f57af5804a88@77.37.176.99:16656,461254f281d96b7a78a8cb12de6190d3e79dadb0@88.99.13.85:26656,2dd0bc113f2f457effe3d0e091d80303fddf3c6a@161.35.16.147:46656,23a18fe03c6c1b0ccc7eb0d53716ef2ba5887fd3@194.5.152.200:26656,b6b0a2ed2d3101dd7ee4aef4aa00fa43d21e4b16@142.132.130.196:36656,3dbaa4a9b957ac296e197083d120f94112c45607@161.97.115.131:26656,efc3cb98f4033d230c971921b8f25b8ee1239b7c@14.29.132.178:26656,31b592b7b8e37af2a077c630a96851fe73b7386f@138.201.251.62:26656"

sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nibid/config/config.toml


sed -i.default 's/minimum-gas-prices =.*/minimum-gas-prices = "0.025unibi"/g' $HOME/.nibid/config/app.toml

CONFIG_TOML="$HOME/.nibid/config/config.toml"
sed -i 's/timeout_propose =.*/timeout_propose = "100ms"/g' $CONFIG_TOML
sed -i 's/timeout_propose_delta =.*/timeout_propose_delta = "500ms"/g' $CONFIG_TOML
sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $CONFIG_TOML
sed -i 's/timeout_prevote_delta =.*/timeout_prevote_delta = "500ms"/g' $CONFIG_TOML
sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $CONFIG_TOML
sed -i 's/timeout_precommit_delta =.*/timeout_precommit_delta = "500ms"/g' $CONFIG_TOML
sed -i 's/timeout_commit =.*/timeout_commit = "1s"/g' $CONFIG_TOML
sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_TOML
sed -i.default "s/pruning *=.*/pruning = \"custom\"/g" $HOME/.nibid/config/app.toml
sed -i "s/pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/g" $HOME/.nibid/config/app.toml
sed -i "s/pruning-interval *=.*/pruning-interval = \"10\"/g" $HOME/.nibid/config/app.toml




nibid tendermint unsafe-reset-all



sudo tee /etc/systemd/system/cosmovisor-nibiru.service<<EOF
[Unit]
Description=Cosmovisor for Nibiru Node
Requires=network-online.target
After=network-online.target

[Service]
Type=exec
User=<your_user>
Group=<your_user_group>
ExecStart=/home/<your_user>/go/bin/cosmovisor run start --home /home/<your_user>/.nibid
Restart=on-failure
RestartSec=3
Environment="DAEMON_NAME=nibid"
Environment="DAEMON_HOME=/home/<your_user>/.nibid"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_LOG_BUFFER_SIZE=512"
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF




sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl restart nibid && sudo journalctl -u nibid -f -o cat


