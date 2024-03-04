// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8 .2 < 0.9 .0;

import "./Ownable.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract StorageData is Ownable {

    uint256 number;
    address contractoLogica;

    modifier soloContratoLogica {
        require(msg.sender == address(contractoLogica), "No tienes permisos");
        _;
    }

    function getNumber() public view returns(uint256) {
        return number;
    }

    function setNumber(uint256 number_) public soloContratoLogica {
        number = number_;
    }

    function setStorageLogicContract(address logica) public onlyOwner {
        contractoLogica = logica;
    }
}

contract StorageLogic {

    StorageData contratoDatos;

    constructor(StorageData datos) {
        contratoDatos = datos;
    }
    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        contratoDatos.setNumber(num);
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns(uint256) {
        return contratoDatos.getNumber();
    }
}


contract StorageLogicB {

    StorageData contratoDatos;

    constructor(StorageData datos) {
        contratoDatos = datos;
    }
    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        contratoDatos.setNumber(num);
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns(uint256) {
        return contratoDatos.getNumber();
    }


    function addThree() public {
        contratoDatos.setNumber(contratoDatos.getNumber() + 3);
    }
}