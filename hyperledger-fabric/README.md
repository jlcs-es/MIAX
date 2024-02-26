# Hyperledger Fabric

## Instalar Fabric 2.5

- Node 18 LTS
- [Prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-2.5/prereqs.html) ya incluidos en la máquina virtual
- [Install script](https://hyperledger-fabric.readthedocs.io/en/release-2.5/install.html) ya incluidos en la máquina virtual

```bash
$ curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh

$ ./install-fabric.sh docker samples binary --fabric-version 2.5.6
```

## Comprobar instalación


1. Cambio de directorio a test-network

```sh
cd ~/hyperledger-fabric/fabric-samples/test-network
```

2. Desplegar red de pruebas

```sh
./network.sh up
```

3. Comprobar ejecución

```sh
docker ps -a
docker logs peer0.org1.example.com
```

4. Eliminar red de pruebas

```sh
./network.sh down
```
