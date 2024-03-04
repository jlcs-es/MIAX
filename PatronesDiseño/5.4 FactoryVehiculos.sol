// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.4;

contract Vehiculo {

    enum TipoVehiculo {
        TURIMO,
        CAMION,
        AUTOBUS
    }

    uint8 public numPuertas;
    bool public esGasolina;
    address private propietario;
    TipoVehiculo public tipo;
    string public matricula;
    string public modelo;
    address[] private asegurados;

    constructor (uint8 numPuertas_, bool esGasolina_, address propietario_, TipoVehiculo tipo_, string memory matricula_, string memory modelo_) {
        numPuertas = numPuertas_;
        esGasolina = esGasolina_;
        matricula = matricula_;
        propietario = propietario_;
        tipo = tipo_;
        modelo = modelo_;
        asegurados.push(propietario_);
    }

    function getPropietario() public view returns (address) {
        return propietario;
    }

    function anyadirAsegurado(address nuevoAsegurado) public payable {
        asegurados.push(nuevoAsegurado);
    }

    function getCombustible() public view returns (string memory combustible_) {
        // combustible_ = esGasolina ? "GASOLINA" : "DIESEL";
        if (esGasolina) {
           combustible_ =  "GASOLINA";
        } else {
            combustible_ = "DIESEL";
        }
    }
}

contract RegistroVehiculos2 {
    event VehiculoRegistrado(string matricula, address vehiculo, uint256 total);

    mapping(string => Vehiculo) registro;
    uint256 contador;

    modifier precioExacto() {
        require(msg.value == 1 ether, "no has pagado el precio exacto");
        _;
    }

    function anadirVehiculo(uint8 numPuertas_, bool esGasolina_, address propietario_, Vehiculo.TipoVehiculo tipo_, string memory matricula_, string memory modelo_) precioExacto public payable {
        Vehiculo vehiculo_ = new Vehiculo(numPuertas_, esGasolina_, propietario_, tipo_, matricula_, modelo_);
        registro[vehiculo_.matricula()] = vehiculo_;
        contador = contador + 1;
        emit VehiculoRegistrado(vehiculo_.matricula(), address(vehiculo_), contador);
    }

    function getVehiculo(string memory matricula_) public view returns (Vehiculo) {
        return registro[matricula_];
    }
}