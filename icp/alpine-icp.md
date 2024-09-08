Debido a incompatibilidad de icp con musl, usaremos un contenedor docker para desarrollo:

Descargar la imagen docker:
```
docker pull ghcr.io/dfinity/icp-dev-env:latest
```

Ejecutar un contenedor:

```
docker run -it --rm -v /home/user/icp:/miax -w /miax --network host --name icpdev ghcr.io/dfinity/icp-dev-env:latest bash
```


Permisos de escritura para nosotros (mala práctica):
```
chmod 774 -R <directorio>
```

Dentro del contenedor

```
dfx start --clean --background
```

O bien desde otra terminal:
```
docker exec -it icpdev bash
dfx start --clean
```


Desde la otra terminal en el proyecto:
```
dfx deploy
```