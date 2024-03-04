// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.4;

import "./Ownable.sol";

contract RBAC is Ownable {
    mapping(string => bool) private _roles;
    mapping(address => mapping(string => bool)) private _accountsRoles;

    modifier roleExists(string memory role) {
        require(_roles[role], "Role does not exists");
        _;
    }

    modifier roleNotExists(string memory role) {
        require(_roles[role] == false, "Role exists");
        _;
    }

    modifier hasRole(address account, string memory role) {
        require(_roles[role], "Role does not exists");
        require(_accountsRoles[account][role], "Account does not have the role");
        _;
    }

    function addRole(string memory role) roleNotExists(role) onlyOwner public {
        _roles[role] = true;
    }

    function setRole(address account, string memory role) roleExists(role) onlyOwner public {
        _accountsRoles[account][role] = true;
    }
}

contract MiContrato is RBAC {
    function doSomething() hasRole(msg.sender, "admin") public {

    }
}