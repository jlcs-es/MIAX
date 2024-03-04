// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8 .2 < 0.9 .0;

abstract contract BasicProxy {


    function _implementation() internal view virtual returns(address);

    fallback() external payable virtual {
        (bool success, bytes memory data) = _implementation().delegatecall(msg.data);
    }

}

contract StorageData is BasicProxy {

    address public logicContract;
    uint256 public number;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    function _implementation() internal view override returns(address) {
        return logicContract;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns(uint256) { // devolver el propio número o llamar a retrieve the StorageLogic
        return number;
    }
}

contract StorageLogic {

    address public logicContract;
    uint256 public number;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns(uint256) {
        return number;
    }

    /**
     * @dev Add 3 to variable 
     */

    function addThree() public {
        number = number + 3;
    }



    function hashRetrieve() public pure returns(bytes memory) {
        return abi.encodeWithSignature("retrieve()"); // 0x2e64cec1 -> primeros 8 caracteres de aplicar Keccak-256 a 'retriveve()'
    }

    function hashStore(uint num) public pure returns(bytes memory) {
        return abi.encodeWithSignature("store(uint256)", num); // store(5) =  0x6057361d0000000000000000000000000000000000000000000000000000000000000005
    }

    function hashAddThree() public pure returns(bytes memory) {
        return abi.encodeWithSignature("addThree()"); // 0xe2fbc880
    }

}



abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result: = delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return (0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns(address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }


}