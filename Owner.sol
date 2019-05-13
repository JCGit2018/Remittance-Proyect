pragma solidity ^0.5.0;

contract Owner {
    address private owner;

    modifier onlyOwner() {
        require (msg.sender == owner, "Only owner can make changes");
        _;
    }
    
    constructor () public {
        owner = msg.sender;
    }
}