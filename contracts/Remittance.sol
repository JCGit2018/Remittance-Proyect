/*Alice creates a Remittance contract with Ether in it and a puzzle.
Alice sends a one-time-password to Bob; over SMS, say.
Alice sends another one-time-password to Carol; over email, say.
Bob treks to Carol's shop.
Bob gives Carol his one-time-password.
Carol submits both passwords to Alice's remittance contract.
Only when both passwords are correct does the contract yield the Ether to Carol.
Carol gives the local currency to Bob.
Bob leaves.
Alice is notified that the transaction went through.*/

pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Pausable.sol";
  
  
  contract Remittance is Pausable{
      
    struct Remittances {
        address exchanger;
        address thesender; 
        uint    thelimit;
        bool    withdraw; //True of false if the funds have been withdrawn by Carol or Alice after timelimit
    }
    
      mapping(bytes32 => Remittances) public remittances; 
      
            
      //event logs
      event LogContractCreated(address owner);
      event LogRemitSend(address sender, address exchanger, uint limit, bytes32 hashOfBoth);
      event LogWithdrawal(address sender, address receiver, uint amount);
      event LogTimeUpWithdraw(address sender, uint amount);
      
      mapping(address => uint) public balances; 
      
      
      
      
    constructor() public{
       emit LogContractCreated(msg.sender);
      }
      
  
      
    function sendRemittance(bytes32 hashOfBoth, uint limit, address exchanger)
    public
    payable
    returns (bool success)
    {
    require(msg.value > 0);
    require(limit <= 604800);
    remittances[hashOfBoth].exchanger = exchanger;
    remittances[hashOfBoth].thelimit = limit + block.timestamp; 
    remittances[hashOfBoth].thesender =getOwner();
    remittances[hashOfBoth].withdraw = false;

    //Send owner of contract a cut 
    balances[getOwner()] += msg.value/20; 
    balances[exchanger] += msg.value-(msg.value/20);
    
    emit LogRemitSend(msg.sender, exchanger, limit, hashOfBoth);
    return true;
    }
      
 
    function exchangerWithdrawl(string memory pwsswordBob, string memory passwordCarol)
    public
    returns (bool success)
    {
    bytes32 completepass = keccak256(abi.encodePacked(pwsswordBob, passwordCarol));
    address exchanger = remittances[completepass].exchanger; 
    require(msg.sender == exchanger);
    require(block.timestamp >= remittances[completepass].thelimit);
    require(balances[msg.sender] > 0);
    require(remittances[completepass].withdraw == false);
    uint tosend = balances[msg.sender];
    balances[msg.sender] = 0;
    remittances[completepass].withdraw = true; 
    msg.sender.transfer(tosend);
    emit LogWithdrawal(remittances[completepass].thesender, exchanger, tosend);   
    return true;
   }
    
    /* If Carol fails to withdrawl funds before the timeline ends, 
Alice needs to be able retrieve funds. This function allows Alice to withdrawl funds after the deadline.*/

    function timeLimitUp(bytes32 hashOfBoth)
    public
    returns (bool success)
    {
    address owner=getOwner();
    require(block.timestamp >=  remittances[hashOfBoth].thelimit);
    require(remittances[hashOfBoth].thesender == owner);
    require(remittances[hashOfBoth].withdraw == false);

    /* Allowing Alice  to withdraw the amount that she allotted to Carol. */
    uint tosend = balances[remittances[hashOfBoth].exchanger];
    balances[remittances[hashOfBoth].exchanger] = 0; 
    remittances[hashOfBoth].withdraw = true; 
    msg.sender.transfer(tosend);
    emit LogTimeUpWithdraw(msg.sender, tosend);
    return true;
   }  
      
      
 }
