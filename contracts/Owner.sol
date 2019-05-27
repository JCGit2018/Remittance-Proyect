pragma solidity ^0.5.0;


contract Owner {
    address private owner;
    event LogChangeOwner(address sender, address theNewOwner);

    modifier onlyOwner() {
        require (msg.sender == owner, "Only owner can make changes");
        _;
    }
    
    constructor () public {
        owner = msg.sender;
    }
    
    function getOwner()  public view returns   (address myOwner) {
        return owner;
    }
 
    function changeOwner(address newOwner) public onlyOwner returns (bool success) {
        require(newOwner != address(0), "Owner: new owner is the zero address");
        owner = newOwner;
        emit LogChangeOwner(msg.sender, newOwner);
        return true;
    }
}
