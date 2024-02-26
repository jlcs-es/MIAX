# Práctica MIAX

- Implementar un contrato básico de Creación (C), Lectura (R), Actualización (U) y Borrado (D) - CRUD - de activos.
- Extender el contrato con funciones de Transferencia (T) de activos.

Un activo es un recurso cualquiera que podamos serializar (json) e identificar de manera unívoca.
Para la práctica utilizaremos vehículos.

## Red

Utilizaremos la red `test-network` con un canal `mychannel`.
No utilizaremos CouchDB, de modo que el almacenamiento serán pares clave-valor de tipo string.


## Lenguaje del chaincode

Utilizaremos JavaScript, con el que estamos familiarizados por los scripts y tests en Ethereum.

El directorio actual está preparado con el esqueleto de la aplicación.

Opcionalmente se puede trabajar con Go o Java. Se deja como trabajo del alumno preparar el directorio para proyectos en Go o Java.

## Interfaz

La interfaz de chaincode a implementar consistirá en:

El recurso que representa un activo:

```json
{
    color: string,
    itv: string,
    marca: string,
    matriculacion: {
        matricula: string,
        pais: string,
        year: string
    },
    modelo: string,
    propietario: string
}
```

```javascript
CreateAsset(ctx, id, color, itv, marca, matricula, pais, year, modelo, propietario)
ReadAsset(ctx, id): string // JSON string del coche
UpdateAsset(ctx, id, color, itv)
DeleteAsset(ctx, id)

AssetExists(ctx, id)

TransferAsset(ctx, id, nuevoPropietario)
```

## Directorio de trabajo

- En `~/MIAX/hyperledger-fabric/practica-miax/` se proporciona el paquete NodeJS preparado para implementar chaincode.
- En `~/MIAX/hyperledger-fabric/practica-miax/src/coches.js` se proporciona el esqueleto del chaincode a implementar.

## Hyperledger Fabric SDK

Para implementar el chaincode, necesitaremos utilizar el SDK de Fabric que nos permite conectar con el almacenamiento persistente.

El método más sencillo es heredar de la clase `Contract` del paquete `fabric-contract-api`.
Todas las funciones definidas dentro de la nueva clase serán expuestas como parte del chaincode.

IMPORTANTE: Todas las funciones reciben como primer parámetro un _contexto_ que da acceso a más funciones del SDK.
El más importante es el [`stub`](https://hyperledger.github.io/fabric-chaincode-node/main/api/fabric-shim.ChaincodeStub.html).

El modo de utilización es el siguiente:

```js
// Read
const bufferBytes = await ctx.stub.getState(id)

const stateAsString = bufferBytes.toString()
const stateAsObject = JSON.parse(stateAsString)

// Write with deterministic json
await ctx.stub.putState(id, Buffer.from(  stringify(sortKeysRecursive( <assetVariable> ))  ))
```

Documentación:
- [setState](https://hyperledger.github.io/fabric-chaincode-node/main/api/fabric-shim.ChaincodeStub.html#getState__anchor)
- [putState](https://hyperledger.github.io/fabric-chaincode-node/main/api/fabric-shim.ChaincodeStub.html#putState__anchor)


## Mejoras opcionales

- Validar datos de entrada. Por ejemplo: el país debe ser un código de país válido, el año cuatro dígitos...
- Ampliar información de la ITV.
- Control de acceso:
    - Modificar el atributo del propietario para incluir los datos criptográficos del usuario (certificado del MSP con el que firma la transacción).
    - En las funciones `Update`, `Delete` y `Transfer` comprobar que el usuario que envía la transacción es realmente el propietario del coche.
    - Utiliza funciones del SDK para obtener las identidades: [getCreator](https://hyperledger.github.io/fabric-chaincode-node/main/api/fabric-shim.ChaincodeStub.html#getCreator__anchor)


## Despliegue del chaincode en Test Network

1. Cambio de directorio a test-network

```sh
cd ~/MIAX/hyperledger-fabric/fabric-samples/test-network
```

2. Desplegar red de pruebas

```sh
./network.sh up createChannel -c mychannel -ca
```

3. Desplegar CC utilizando el script de ayuda

```sh
./network.sh deployCC -c mychannel -ccn coches -ccv 1.0 -ccl javascript -ccs 1 -ccp ../../practica-miax/
```

Recordamos qué hace cada parámetro del comando con la ayuda:

```sh
./network.sh -h
```

## Invocar al chaincode

1. Desde el directorio de test-network

```sh
cd ~/MIAX/hyperledger-fabric-beta/fabric-samples/test-network
```


2. Configurar variables de entorno para impersonar al `User1@Org1MSP`

```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051
export TARGET_TLS_OPTIONS=(-o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt")
```

3. Invocar el chaincode firmando una Tx Proposal para los nodos peer

```bash
peer chaincode invoke "${TARGET_TLS_OPTIONS[@]}" -C mychannel -n coches -c '{"function":"CreateAsset","Args":["Asset1","blue","valid","Toyota","1234JKV", "ES", "2020", "Yaris", "12345678-H"]}'
```

4. Invocar una query para obtener información sin generar nuevas transacciones

```bash
peer chaincode query -C mychannel -n coches -c '{"function":"ReadAsset","Args":["Asset1"]}' | jq
```


## Actualizar chaincode

Tras realizar cambios en el código, podemos volver a desplegar el mismo chaincode aumentando la versión y número de secuencia:

```bash
./network.sh deployCC -c mychannel -ccn coches -ccv 2.0 -ccl javascript -ccs 2 -ccp ../../practica-miax/
```

