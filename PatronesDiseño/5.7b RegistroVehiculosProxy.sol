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


abstract contract BasicProxy {


    function _implementation() internal view virtual returns(address);

    fallback() external payable virtual {
        (bool success, bytes memory data) = _implementation().delegatecall(msg.data);
    }

}


contract RegistroVehiculosData is BasicProxy {

    address public logicContract;
    uint256 public contador;
    mapping(string => Vehiculo) registro;

    // event VehiculoRegistrado(string matricula, address vehiculo, uint256 total);

    constructor(address logic) {
        logicContract = logic;
    }

    function setLogic(address logic) public {
        logicContract = logic;
    }

    function _implementation() internal view override returns(address) {
        return logicContract;
    }

    function getVehiculo(string memory matricula_) public view returns (Vehiculo) {
        return registro[matricula_];
    }
}


contract RegistroVehiculosLogic {

    address public logicContract;
    uint256 public contador;
    mapping(string => Vehiculo) registro;
    event VehiculoRegistrado(string matricula, address vehiculo, uint256 total);

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

    
    function hashAnadirVehiculo(uint8 numPuertas_, bool esGasolina_, address propietario_, Vehiculo.TipoVehiculo tipo_, string memory matricula_, string memory modelo_) public pure returns(bytes memory) {
        return abi.encodeWithSignature("anadirVehiculo(uint8,bool,address,uint8,string,string)", numPuertas_, esGasolina_, propietario_, tipo_, matricula_, modelo_); // 0x8a02ee38000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000010000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000007303030304d4c4d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004466f726400000000000000000000000000000000000000000000000000000000
    }
}