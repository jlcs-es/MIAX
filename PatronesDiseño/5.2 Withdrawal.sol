// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Auction {
    address payable public winner;
    uint public mostSent;

    /// The amount of Ether sent was not higher than
    /// the currently highest amount.
    error NotEnoughEther();

    constructor() payable {
        winner = payable(msg.sender);
        mostSent = msg.value;
    }

    function bid() public payable {
        if (msg.value <= mostSent) revert NotEnoughEther();
        // This line can cause problems (explained below).
        winner.transfer(msg.value);
        winner = payable(msg.sender);
        mostSent = msg.value;
    }
}

contract AuctionWithdrawal {
    address payable public winner;
    uint public mostSent;
    mapping (address => uint) pendingWithdrawals;

    /// The amount of Ether sent was not higher than
    /// the currently highest amount.
    error NotEnoughEther();

    constructor() payable {
        winner = payable(msg.sender);
        mostSent = msg.value;
    }

    function bid() public payable {
        if (msg.value <= mostSent) revert NotEnoughEther();
        pendingWithdrawals[winner] += msg.value;
        winner = payable(msg.sender);
        mostSent = msg.value;
    }

    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}