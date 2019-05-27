pragma solidity ^0.5.0;

import "./Owner.sol";

contract Pausable is Owner {
    bool private paused;

    //event LogPaused (bool newState, address pausedBy);
    event LogPaused (address pausedBy);
    event LogResumedContract(address resumedBy);
    
    modifier notPaused() {
        require (!paused, "Contract paused");
        _;
    }

    modifier whenPaused() {
        require (paused, "Contract not paused");
        _;
    }

    constructor() public {
        paused = false;
    }

    function contractPaused() public onlyOwner notPaused returns (bool success){
        //require(!paused);
        paused= true;
        emit LogPaused(msg.sender);
        return true;
    }

   function getPaused()  public view returns   (bool myPauseState) {
        return paused;
    }

    function resume() public onlyOwner whenPaused returns (bool success){
        paused = false;
        emit LogResumedContract(msg.sender);
        return true;
    }
}
