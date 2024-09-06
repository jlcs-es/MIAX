Ease of use with docker images:
```
nargo() { docker run -it --rm -v ${PWD}:/noirsession nargo $@; }
bb() { docker run -it --rm -v ${PWD}:/bbsession bb $@; }
```

Init  project
```
cd noirsession
nargo new hello_world
```

Build hello world
```
cd hello_world
nargo check
```


To write files:
```
doas chmod 664 <yourfile>

doas chmod 664 Prover.toml
```

Once Prover.toml is filled:
```
nargo execute witness-name

bb prove -b ./target/hello_world.json -w ./target/witness-name.gz -o ./target/proof
bb write_vk -b ./target/hello_world.json -o ./target/vk
bb verify -k ./target/vk -p ./target/proof
```