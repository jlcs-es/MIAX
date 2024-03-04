// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8;

import "./ERC/ERC721.sol";
import "./Utils/Ownable.sol";
import "./VehiculoMetadata.sol";

/**
* @dev Contrato para nuestro modulo Registro tráfico implementado con estandar ERC71 de tokens no fungibles. Cada vehículo es único.
*/
contract RegistroTrafico is ERC721, Ownable {

    mapping(bytes32 => VehiculoMetadata) mapMatriculaVehiculoMetadata; // mapping que asocia una matricula con el contrato creado VehiculoMetadata
    bytes32[] matriculasRegistradas;

    /**
    * @dev Constructor por defecto que inicializa el nombre y simbolo
    */
    constructor() ERC721("NFT Vehiculos", "VEH") {
    }


    /**
     * @dev Funcion para registrar un vehículo existente a nombre de una cuenta to_. Solo el dueño del contrato puede realizar esta accion.
     */
    function registrarNuevoVehiculo(address to_, uint8 numPuertas_, bool esGasolina_, bytes32 matricula_, VehiculoMetadata.TipoVehiculo tipo_, string memory modelo_) public onlyOwner {
        require(!existeMatricula(matricula_), "Vehiculo ya creado"); // comprobar que no el vehículo no está ya registrado
        VehiculoMetadata vehiculo = new VehiculoMetadata(numPuertas_, esGasolina_, matricula_, tipo_, modelo_); // contrato con propiedades del vehículo
        mapMatriculaVehiculoMetadata[matricula_] = vehiculo; //asociación matricula-VehiculoMetadata
        matriculasRegistradas.push(matricula_);
        _mint(to_, matricula_); //creamos el NFT para el tokenId y lo asociamos al TO
    }

    /**
     * @dev Funcion para determinar si una matricula ha sido registrada
     */
    function existeMatricula(bytes32 matricula_) public view returns(bool) {
        return address(mapMatriculaVehiculoMetadata[matricula_]) != address(0);
    }

    /**
     * @dev Funcion para devolver la lista de vehiculos registrados para una cuenta
     */
    function getListaVehiculosPropietario(address account_) public view returns(VehiculoMetadata[] memory vehiculos_) {
        uint total = balanceOf(account_);
        VehiculoMetadata[] memory vehiculos = new VehiculoMetadata[](total);
        uint count = 0;
        for (uint i = 0; i < matriculasRegistradas.length; i++) {
            if (ownerOf(matriculasRegistradas[i]) == account_) {
                vehiculos[count] = mapMatriculaVehiculoMetadata[matriculasRegistradas[i]];
                count++;
            }
        }
        return (vehiculos);
    }

    /**
     * @dev Funcion para devolver la lista completa de vehiculos registrados
     */
    function getListaVehiculos() public view returns(VehiculoMetadata[] memory vehiculos_, address[] memory propietarios_) {
        address[] memory propietarios = new address[](matriculasRegistradas.length);
        VehiculoMetadata[] memory vehiculos = new VehiculoMetadata[](matriculasRegistradas.length);
        for (uint i = 0; i < matriculasRegistradas.length; i++) {
            vehiculos[i] = mapMatriculaVehiculoMetadata[matriculasRegistradas[i]];
            propietarios[i] = ownerOf(matriculasRegistradas[i]);
        }
        return (vehiculos, propietarios);
    }
}