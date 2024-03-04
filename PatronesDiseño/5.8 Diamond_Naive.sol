// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8 .2 < 0.9 .0;

contract Storage {

    uint public number;
    address public satelliteContract1;
    address public satelliteContract2;

    constructor(address _satelliteContract1, address _satelliteContract2) {
        satelliteContract1 = _satelliteContract1;
        satelliteContract2 = _satelliteContract2;
    }

    // version con llamada a funcion pasando parámetros
    function addThreeV1() public {
        number = SatelliteContract1(satelliteContract1).addThree(number);
    }

    // version usando delegatecall
    function addThreeV2() public {
        (bool success, bytes memory data) = satelliteContract2.delegatecall(
            abi.encodeWithSignature("addThree()")
        );
    }

}

contract SatelliteContract1 {

    function addThree(uint number) public pure returns(uint256) {
        return number + 3;
    }
}

contract SatelliteContract2 {

    uint public number;

    function addThree() public {
        number = number + 3;
    }
}