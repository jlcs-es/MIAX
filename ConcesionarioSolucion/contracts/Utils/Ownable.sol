// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Ownable {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario puede hacer esto");
        _;
    }
}