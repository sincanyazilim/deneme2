
## Node Kurulumu


#### İlk kurulum

```http

```
#### Cüzdan Oluşturma

```http
nibid keys add name     # name yerine bir cüzdan ismi yazın

nibid keys show name -a # name yerine kendi cüzdan isminizi buraya girin wallet adresiniz çıkar
```


#### Validator

```http
nibid tx staking create-validator \
--amount 10000000unibi \
--commission-max-change-rate "0.1" \
--commission-max-rate "0.20" \
--commission-rate "0.1" \
--min-self-delegation "1" \
--pubkey=$(nibid tendermint show-validator) \
--moniker <your_moniker> \
--chain-id nibiru-testnet-1 \
--gas-prices 0.025unibi \
--from <key-name>
```

#### Delegatör olma

```http
nibid tx staking delegate validator_adresi 10000000unibi --from wallet --chain-id nibiru-testnet-1 --fees 5000unibi
```

#### Senkronizasyon kontrolü

```http
nibid status 2>&1 | jq .SyncInfo
```

## Kullanım/Örnekler

```javascript
deneme



baya bir deneme 

-- deneme
```
