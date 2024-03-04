// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/**
* @dev Contrato que guarda las propiedades de un vehiculo
*/
contract VehiculoMetadata {

    enum TipoVehiculo { TURIMO, CAMION, AUTOBUS }

    uint8 public numPuertas;
    bool public esGasolina;
    bytes32 public matricula;
    TipoVehiculo public tipo;
    string public modelo;

    constructor(uint8 numPuertas_, bool esGasolina_, bytes32 matricula_, TipoVehiculo tipo_, string memory modelo_) {
        numPuertas = numPuertas_;
        esGasolina = esGasolina_;
        matricula = matricula_;
        tipo = tipo_;
        modelo = modelo_;
    }

    function getInfo() public view returns (uint8 numPuertas_, bool esGasolina_, bytes32 matricula_, TipoVehiculo tipo_, string memory modelo_) {
        return (numPuertas, esGasolina, matricula, tipo, modelo);
    }
}