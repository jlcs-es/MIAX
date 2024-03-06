// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./Ownable.sol";

contract Storage is Ownable {

    uint256 number;
    bool paused;

    modifier notPaused() {
        require(!paused, "contract is paused");
        _;
    }

    function pause() onlyOwner public {
        paused = true;
    }

    function unpause() onlyOwner public {
        paused = false;
    }

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) notPaused public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}
