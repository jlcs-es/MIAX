// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8;

import "./Utils/Ownable.sol";
import "./EuroTokenizado.sol";
import "./RegistroTrafico.sol";


/**
* @dev Contrato para nuestro modulo Concesionario
*/
contract Concesionario is Ownable {

    /**
    * @dev Estructura con la información de un anuncio
    */
    struct Anuncio {
        uint256 id;
        bytes32 matricula;
        uint256 precioVenta;
        address propietario;
        bool existe;
    }

    EuroTokenizado private euroTokenizado;
    RegistroTrafico private registroTrafico;

    mapping(bytes32 => Anuncio) public mapAnuncios; // mapping de matricula a anuncio para buscar rapidamente si hay anuncio para un vehiculo
    uint256 private numAnuncios; // contador de anuncios para el id
    Anuncio[] public listaAnuncios; // array de anuncios para mostrarlos en pantalla

    /**
    * @dev modificador para comprobar si el sender es el propietario del vehiculo
    */
    modifier esPropietarioVehiculo(bytes32 matricula_) {
        require(msg.sender == registroTrafico.ownerOf(matricula_), "Solo el propietario del vehiculo puede realizar esta accion");
        _;
    }

    /**
    * @dev Constructor al que se le pasa la direccion del contrato EuroTokenizado y RegistroTrafico
    */
    constructor(EuroTokenizado euroTokenizado_, RegistroTrafico registroTrafico_) {
        euroTokenizado = euroTokenizado_;
        registroTrafico = registroTrafico_;
        numAnuncios = 0;
    }

    /**
    * @dev Funcion para publicar un anuncio de venta de un vehículo. Solo puede publicar anuncio el propietario
    */
    function publicarAnuncioVenta(bytes32 matricula_, uint256 precioVenta_) public esPropietarioVehiculo(matricula_) {
        require(!existeAnuncioVehiculo(matricula_), "Ya hay un anuncio publicado para este vehiculo"); // comprobar que no existe ya un anuncio para este vehiculo
        require(precioVenta_ > 0, "El precio debe ser mayor que 0"); // comprobar que el precio de venta es mayor que 0
        numAnuncios++;
        Anuncio memory anuncio = Anuncio({
            id: numAnuncios,
            matricula: matricula_,
            precioVenta: precioVenta_,
            propietario: msg.sender,
            existe: true
        });
        mapAnuncios[matricula_] = anuncio;
        listaAnuncios.push(mapAnuncios[matricula_]);
    }

    /**
    * @dev Funcion para eliminar un anuncio existente
    */
    function cancelarAnuncioVenta(bytes32 matricula_) public esPropietarioVehiculo(matricula_) {
        require(existeAnuncioVehiculo(matricula_), "No hay anuncio de venta para este vehiculo");
        delete mapAnuncios[matricula_];
    }

    /**
    * @dev Funcion para comprar un vehículo en venta. 
    * Requiere que el vendedor haya dado permiso approve a este contrato sobre el contrato de RegistroTrafico y 
    * que el comprador haya dado permiso approve a este contrato para mover el dinero en EuroTokenizado
    */
    function comprarAnuncio(bytes32 matricula_) public {
        require(existeAnuncioVehiculo(matricula_), "No hay anuncio de venta para este vehiculo");
        Anuncio storage anuncio = mapAnuncios[matricula_];
        address propietario = registroTrafico.ownerOf(matricula_);
        euroTokenizado.transferFrom(msg.sender, propietario, anuncio.precioVenta);
        registroTrafico.transferFrom(propietario, msg.sender, matricula_);
        anuncio.existe = false;
    }

    /**
    * @dev Funcion para comprobar si ya hay un anuncio publicado para un vehículo
    */
    function existeAnuncioVehiculo(bytes32 matricula_) public view returns(bool) {
        return mapAnuncios[matricula_].existe;
    }

    /**
    * @dev Funcion para obtener información de un anuncio publicado para un vehiculo con cierta matricula
    */
    function getAnuncio(bytes32 matricula) public view returns(uint256 id_, bytes32 matricula_, uint256 precioVenta_, address propietario_, bool existe_) {
        Anuncio storage anuncio = mapAnuncios[matricula];
        return (anuncio.id, anuncio.matricula, anuncio.precioVenta, anuncio.propietario, anuncio.existe);
    }

    /**
    * @dev Obtener la lista completa de vehiculos con anuncio de venta
    */
    function getListaVehiculosConAnuncio() public view returns(bytes32[] memory matriculas_) {
        uint count = 0;
        for (uint i = 0; i < listaAnuncios.length; i++) {
            if (listaAnuncios[i].existe)
                count++;
        }
        if (count > 0) {
            matriculas_ = new bytes32[](count);
            count = 0;
            for (uint i = 0; i < listaAnuncios.length; i++) {
                if (listaAnuncios[i].existe) {
                    matriculas_[count] = listaAnuncios[i].matricula;
                    count++;
                }
            }
        }
    }
}